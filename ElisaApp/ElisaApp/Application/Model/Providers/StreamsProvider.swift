//
//  StreamsProvider.swift
//  ElisaApp
//
//  Created by alexandr galkin on 19.05.2022.
//

import Foundation
import RxSwift
import RxRelay
import SwiftLazy
import UIKit
import AVFoundation
import HaishinKit
import SocketIO

enum MicState {
    case mute
    case unmute
}

protocol StreamsProvider {
    var state: BehaviorRelay<StreamsProviderState> { get }
    
    func setCampaign(_ campaign: Campaign, page: Page)
    func configureStream()
    func joinStream()
    func leaveStream(comletion: (() -> Void)?)
    func switchCamera()
    func changeBrightness(value: Double)
    func changeCameraExposureMode(_ mode: AVCaptureDevice.ExposureMode)
    func loadRTMPConnectionCredentials()
    func switchStreamOrientation()
    func saveEnterToBackgroundTime(_ time: Date)
    func getBackgroundTime() -> Int?
    func resumeStream()
    func upNodes()
    func forceCloseStreamScreen()
    func micManage()
    func pauseStream()
}

struct StreamsProviderState: UpdatableStruct {
    enum StreamState: Equatable {
        case initiated, preparing, started(Date), failed, finished, waiting, connecting
    }
    
    enum StreamStartError: String {
        case notScheduled = "This stream wasn't scheduled and might take up to 3 minutes to start"
        case waitingTimeout = "Unable to start the stream"
    }
    
    var campaign: Campaign?
    var localStreamView: UIView?
    var streamState: StreamState = .initiated
    var page: Page?
    var rtmpUrl: String?
    var rtmpKey: String?
    var rtmpStreamResolutionWidth: Int = 1920
    var rtmpStreamResolutionHeight: Int = 1080
    var isLoading: Bool = false
    var overlayURL: URL?
    var isSessionScheduled: Bool = false
    var streamError: StreamStartError?
    var shouldReloadOverlay: Bool = false
    var streamStatistic: RTMPStatistics?
    var micState: MicState = .unmute
}

final class StreamsProviderImpl {
    // MARK: - Public Properties
    
    let state = BehaviorRelay<StreamsProviderState>(value: StreamsProviderState())
    
    // MARK: - Private Properties
    
    private let disposeBag = DisposeBag()
    private let streamsService: Lazy<StreamsRTMPService>
    private let userProperties: UserProperties
    private let saveTimeKey = "savedTime"
    private let socketManager: SocketManager
    private let userDefaultsManager: UserDefaultsManager
    private let cameraManager: RTMPCameraManager
    private let loggingService: LoggingService
    
    private var connectionClosedByUser: Bool = false
    private var startingStreamDate: Date?
    private var streamManager: RTMPStreamManager
    private weak var timer: Timer?
    private let totalTimerRepeats = 180
    private var currentTimerRepeate = 0
    private var isAlreadyLoadingCredentials: Bool = false
    private var isSartButtonWasTapped: Bool = false
    private var overlayBaseUrl: String = ""
    var resolution = ""
    var aVCaptureVideoStabilizationMode = 1
    // MARK: - Init
    
    init(streamManager: RTMPStreamManager,
         streamsService: Lazy<StreamsRTMPService>,
         userProperties: UserProperties,
         socketManager: SocketManager,
         userDefaultsManager: UserDefaultsManager,
         cameraManager: RTMPCameraManager,
         loggingService: LoggingService) {
        self.streamManager = streamManager
        self.streamsService = streamsService
        self.userProperties = userProperties
        self.socketManager = socketManager
        self.userDefaultsManager = userDefaultsManager
        self.cameraManager = cameraManager
        self.loggingService = loggingService
        configureObservables()
        userDefaultsManager.removeValue(for: .saveTimeKey)
    }
    
    private func configureObservables() {
        streamManager.events.subscribe(onNext: { [weak self] event in
            switch event {
            case .didUpdateLocalStream(let view):
                self?.state.update(\.localStreamView, to: view)
            case .didChangeConnection(let state):
                switch state {
                case .connectClosed:
                    self?.state.update(\.streamState, to: .waiting)
                    
                case .connectFailed, .connectRejected:
                    self?.state.update(\.streamState, to: .failed)
                case .connectSuccess:
                    if let startingStreamDate = self?.startingStreamDate {
                        self?.state.update(\.streamState, to: .started(startingStreamDate))
                        
                    } else {
                        self?.startingStreamDate = Date()
                        self?.state.update(\.streamState, to: .started(self!.startingStreamDate!))
                    }
                default: break
                }
            case .didUserCloseConnection:
                self?.state.update(\.streamState, to: .finished)
            case .maxReconnectTryReached:
                self?.streamsService.value.closeStream(completion: {[weak self] result in
                    self?.streamManager.unPublish()
                    self?.streamsService.value.disconnectSocket()
                })
            case .errorStreamPublishing:
                self?.state.update(\.streamState, to: .failed)
            case .streamStatistics(let statistic):
                self?.state.update(\.streamStatistic, to: statistic)
            }
        }).disposed(by: disposeBag)
        
        cameraManager.state
            .map(\.currentPosition)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] state in
            guard let self else { return }
            
            switch state {
            case .unspecified:
                self.updateOverlayUrl(isMirrored: nil)
            case .back:
                self.updateOverlayUrl(isMirrored: nil)
            case .front:
                self.updateOverlayUrl(isMirrored: true)
            @unknown default:
                break
            }
            
        }).disposed(by: disposeBag)
        
        socketManager.onEvent.subscribe(onNext: { [weak self] event in
            guard let `self` = self else { return }
            self.loggingService.logMessage(topic: .socketInput(event.event.rawValue))
            switch event.event {
            case .streamStopped:
                if !self.connectionClosedByUser {
                    self.leaveStream()
                }
            case .statusChange:
                if let status = event.data?[0] as? SocketIO.SocketIOStatus, status == .connected && self.state.value.streamState == .connecting {
                    self.state.update(\.streamState, to: .initiated)
                }
            case .nodesReady:
                self.loadRTMPConnectionCredentials()
            case .streamInited:
                self.isAlreadyLoadingCredentials = false
                if let data = event.data?[0] as? [String: Any],
                   let rtmpUrl = data["rtmpUrl"] as? String,
                    let rtmpKey = data["rtmpKey"] as? String,
                   self.state.value.streamState == .preparing {
                    self.state.update(\.rtmpUrl, to: rtmpUrl)
                    self.state.update(\.rtmpKey, to: rtmpKey)
                    self.joinStream()
                }
            case .socketError:
                if let data = event.data?[0] as? [String: Any], let errorCode = data["code"] as? Int {
                    let error = SocketError(rawValue: errorCode)
                    switch error {
                    case .badRequest, .internalServerError, .instanceCreateError, .streamingInitElisaAuthError:
                        self.state.update(\.streamError, to: .waitingTimeout)
                    case .streamingUnexpectedStop:
                        self.leaveStream()
                    default:
                        self.state.update(\.streamState, to: .failed)
                    }
                }
            default: break
            }
        }).disposed(by: disposeBag)
    }
    
    private func updateOverlayUrl(isMirrored: Bool?) {
        guard var url = URL(string: "\(overlayBaseUrl)") else { return }
        
        if let isMirrored {
            let queryItems = [URLQueryItem(name: "mirror", value: "\(isMirrored)")]
            if #available(iOS 16.0, *) {
                url.append(queryItems: queryItems)
            } else {
                guard var urlComponents = URLComponents(string: overlayBaseUrl) else { return }
                urlComponents.queryItems = queryItems
                url = urlComponents.url ?? url
            }
        }
                
        self.state.update(\.overlayURL, to: url)
        self.state.update(\.shouldReloadOverlay, to: true)
        self.state.update(\.shouldReloadOverlay, to: false)
    }
    
    private func createTimer() {
        if timer == nil {
            timer?.invalidate()
            timer = Timer.scheduledTimer(timeInterval: 1.0,
                                         target: self,
                                         selector: #selector(timerHandler),
                                         userInfo: nil,
                                         repeats: true)
        }
    }
    
    @objc private func timerHandler() {
        if currentTimerRepeate < totalTimerRepeats && state.value.streamState == .preparing {
            currentTimerRepeate += 1
            return
        }
        
        if (currentTimerRepeate == totalTimerRepeats && state.value.streamState == .preparing) {
            self.timer?.invalidate()
            self.timer = nil
            self.currentTimerRepeate = 0
            state.update(\.streamState, to: .initiated)
            state.update(\.streamError, to: .waitingTimeout)
            streamsService.value.closeStream(completion: {_ in })
            return
        }
        
        if state.value.streamState == .started(startingStreamDate ?? Date()) {
            self.timer?.invalidate()
            self.timer = nil
        }
    }
}

extension StreamsProviderImpl: StreamsProvider {
    func micManage() {
        switch state.value.micState {
        case .mute:
            streamManager.unmute()
            state.update(\.micState, to: .unmute)
            loggingService.logMessage(topic: .userAction(.switchMic(.mute)))
        case .unmute:
            streamManager.mute()
            state.update(\.micState, to: .mute)
            loggingService.logMessage(topic: .userAction(.switchMic(.unmute)))
        }
    }
    
    func upNodes() {
        guard let campaignId = state.value.campaign?.id, state.value.streamState == .initiated else { return }
        isSartButtonWasTapped = true
        state.update(\.streamState, to: .preparing)
        createTimer()
        streamsService.value.checkScheduledSession(campaignId: campaignId)
        { [weak self] result in
            guard let sSelf = self else { return }

            switch result {
            case .success(let result):
                if result.session != nil {
                    sSelf.state.update(\.isSessionScheduled, to: true)
                    sSelf.loggingService.logMessage(topic: .campaingReady("\(campaignId)", true))
                }
                if !sSelf.state.value.isSessionScheduled {
                    sSelf.state.update(\.streamError, to: .notScheduled)
                    sSelf.loggingService.logMessage(topic: .campaingReady("\(campaignId)", false))
                }
                sSelf.streamsService.value.upNodes()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func loadRTMPConnectionCredentials() {
        guard !isAlreadyLoadingCredentials else { return }
        
        isAlreadyLoadingCredentials = true
        if let token = userProperties.token {
            var config: RTMPStreamManagerImpl.RTMPStreamingConfig = .portrait

            if UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight {
                config = .landscape
            }
                
            state.update(\.rtmpStreamResolutionWidth, to: self.resolution == "720p" ? config.mediumResolution.width : config.hightResolution.width)
            state.update(\.rtmpStreamResolutionHeight, to: self.resolution == "720p" ? config.mediumResolution.height : config.hightResolution.height)

            streamsService.value.emitRTMPCredetnials(witdh: state.value.rtmpStreamResolutionWidth,
                                                    height: state.value.rtmpStreamResolutionHeight,
                                                    elisaToken: token,
                                                    facebookId: state.value.page?.id ?? "")
        }
    }
    
    func setCampaign(_ campaign: Campaign, page: Page) {
        resolution = campaign.resolution ?? ""
        print("Campaign MODE : \(campaign.aVCaptureVideoStabilizationMode )")
        aVCaptureVideoStabilizationMode = campaign.aVCaptureVideoStabilizationMode
        state.update(\.campaign, to: campaign)
        overlayBaseUrl = campaign.hostOverlayURL
        updateOverlayUrl(isMirrored: true)
        state.update(\.page, to: page)
        state.update(\.streamState, to: .connecting)
        streamsService.value.connectSocket(campaignId: state.value.campaign?.id ?? "")
        print("MODE : \(aVCaptureVideoStabilizationMode)")
    }
    
    func configureStream() {
        self.streamManager.captureDevices(isBackCamera: false, disableAdaptiveBitrate: userProperties.disableAdaptiveBitrate ?? false, resolution: self.resolution, aVCaptureVideoStabilizationMode: self.aVCaptureVideoStabilizationMode)
    }
    
    func joinStream() {
        if let rtmpUrl = state.value.rtmpUrl, let rtmpkey = state.value.rtmpKey {
            print("Url for starting stream: \(rtmpUrl)")

            streamManager.publish(rtmpUrl: rtmpUrl, rtmpKey: rtmpkey)
        }
    }
    
    func leaveStream(comletion: (() -> Void)? = nil) {
        self.timer?.invalidate()
        self.timer = nil
        connectionClosedByUser = true
        streamManager.unPublish()
        streamsService.value.closeStream(completion: { result in
            comletion?()
        })
        streamsService.value.disconnectSocket()
    }
    
    func switchCamera() {
        streamManager.rotateCamera()
    }
    
    func changeBrightness(value: Double) {
        try? streamManager.cameraManager.changeExposure(value: value)
    }
    
    func changeCameraExposureMode(_ mode: AVCaptureDevice.ExposureMode) {
        try? streamManager.cameraManager.changeExposureMode(mode)
    }
    
    func switchStreamOrientation() {
        streamManager.rotateScreen()
    }
    
    func saveEnterToBackgroundTime(_ time: Date) {
        userDefaultsManager.removeValue(for: .saveTimeKey)
        userDefaultsManager.set(time, key: .saveTimeKey)
    }
    
    func getBackgroundTime() -> Int? {
        if let enterToBackroundTime: Date = userDefaultsManager.get(key: .saveTimeKey) {
            userDefaultsManager.removeValue(for: .saveTimeKey)
            return Int(Date().timeIntervalSince(enterToBackroundTime)) % 60
        }
        
        return nil
    }
    
    func resumeStream() {
        streamManager.resumeStream()
    }
    
    func pauseStream() {
        streamManager.pauseStream()
    }
    
    func forceCloseStreamScreen() {
        streamManager.stopStreaming()
        timer?.invalidate()
        timer = nil
        streamsService.value.closeStream(completion: { _ in})
        streamsService.value.disconnectSocket()
    }
}

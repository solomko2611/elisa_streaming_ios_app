//
//  StreamsViewModel.swift
//  ElisaApp
//
//  Created by Mikhail Sein on 22.03.2022.
//

import Foundation
import RxSwift
import RxRelay
import UIKit

protocol StreamsViewModel {
    var input: Observable<StreamsInput> { get }
    var output: PublishSubject<StreamsOutput> { get }
    var events: PublishSubject<StreamsEvent> { get }
    
    func setCampaign(_ campaign: Campaign, page: Page)
}

final class StreamsViewModelImpl {
    
    // MARK: - Public Properties
    
    let input: Observable<StreamsInput>
    let output = PublishSubject<StreamsOutput>()
    let events = PublishSubject<StreamsEvent>()
    
    // MARK: - Private Properties
    
    private let streamsProvider: StreamsProvider
    private let permissionManager: PermissionManager
    private let logSerive: LoggingService
    private let disposeBag = DisposeBag()
    private var backgroundTaskIdentifiere = UIBackgroundTaskIdentifier(rawValue: 0)
    
    // MARK: - Initializer
    
    init(streamsProvider: StreamsProvider, permissionManager: PermissionManager, logService: LoggingService) {
        self.streamsProvider = streamsProvider
        self.permissionManager = permissionManager
        self.logSerive = logService
                
        input = Observable.combineLatest(streamsProvider.state, permissionManager.state) { streamsProvider, permissionManager -> StreamsInput in
            var stat: String?
            if let statitics = streamsProvider.streamStatistic {
                stat = String(format: "%@%@%@%@%@%@%@",
                              "Optimal bitrate kbit\\s: \(statitics.optimalBitrate / 1024)",
                              "\nCurrent bitrate kbit\\s: \(statitics.currBitrate / 1024)",
                              "\nWill set new bitrate kbit\\s: \(statitics.newBitrate / 1024)",
                              "\nOut bytes per second: \(statitics.outBytesPerSecond)",
                              "\nIn bytes per second: \(statitics.inBytesPerSecond)",
                              "\nTotal bytes per second: \(statitics.bitrateTotalBytesPerSecond)",
                              "\nCurrent FPS: \(statitics.captureFPS)")
            }
            return StreamsInput(
                campaign: streamsProvider.campaign,
                cameraGranted: permissionManager.capturePermissionStatus == .notDetermined ? nil : permissionManager.capturePermissionStatus == .authorized,
                micGranted: permissionManager.recordPermissionStatus,
                localStreamView: streamsProvider.localStreamView,
				localStreamLayer: streamsProvider.localStreamLayer,
                streamState: streamsProvider.streamState,
                isLoading: streamsProvider.isLoading,
                overlayUrl: streamsProvider.overlayURL,
                streamError: streamsProvider.streamError,
                shouldReloadOverlay: streamsProvider.shouldReloadOverlay,
                statistic: stat,
                micState: streamsProvider.micState
            )
        }
        
        events.subscribe(onNext: { [weak self] event in
            self?.processEvent(event: event)
        }).disposed(by: disposeBag)
        
        streamsProvider.state
            .observe(on: MainScheduler.asyncInstance)
            .map({$0.streamState})
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] state in
                if state == .failed {
                    self?.streamsProvider.leaveStream(comletion: {
                        self?.output.onNext(.showFailed)
                    })
                }
                
                if state == .finished {
                    self?.showFinishAlert()
                }
            })
            .disposed(by: disposeBag)
        
        NotificationCenter.default.addObserver(self, selector: #selector(appWillTerminate), name: UIApplication.willTerminateNotification, object: nil)
    }
    
    // MARK: - Private Methods
    
    private func processEvent(event: StreamsEvent) {
        switch event {
        case .viewDidAppear:
            permissionManager.requestCapturePermission()
            permissionManager.requestRecordPermission()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.streamsProvider.changeCameraExposureMode(.continuousAutoExposure)
            }
            streamsProvider.configureStream()
        case .backPressed:
            streamsProvider.forceCloseStreamScreen()
            logSerive.logMessage(topic: .userAction(.closeStream))
            self.output.onNext(.closeStream)
        case .settingsPressed:
            output.onNext(.settingsPressed)
        case .startPressed:
            showStartStreamAlert()
        case .endPressed:
            let leaveAlert = UIAlertController(title: "Stop stream", message: "Are you sure you want to stop the stream?", preferredStyle: .alert)
            leaveAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            leaveAlert.addAction(UIAlertAction(title: "Stop stream", style: .default, handler: { [weak self] _ in
                self?.streamsProvider.leaveStream(comletion: {
                    self?.showFinishAlert()
                })
            }))
            output.onNext(.confirmLeave(leaveAlert))
            logSerive.logMessage(topic: .userAction(.closeStream))
        case .camSwitchPressed:
            streamsProvider.switchCamera()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.streamsProvider.changeCameraExposureMode(.continuousAutoExposure)
            }
        case .brightnessChanged(let value):
            streamsProvider.changeBrightness(value: value)
        case .rotationEvent:
            streamsProvider.switchStreamOrientation()
        case .appDidEnterToBackground:
            logSerive.logMessage(topic: .userAction(.collapsApp))
            if streamsProvider.state.value.streamState != .initiated {
                streamsProvider.saveEnterToBackgroundTime(Date())
                streamsProvider.pauseStream()
            }
        case .appDidBecomeActive:
            logSerive.logMessage(topic: .userAction(.expandApp))
            if let timeInBackground = streamsProvider.getBackgroundTime() {
                if timeInBackground < 30 && streamsProvider.state.value.streamState != .finished {
                    streamsProvider.resumeStream()
                } else {
                    streamsProvider.leaveStream(comletion: nil)
                    showFinishAlert()
                }
            }
        case .viewDidDisAppear:
            break
        case .micButtonTapped:
            streamsProvider.micManage()
        }
    }
    
    private func showFinishAlert() {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Great job!", message: "Your stream has been finished!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
                self?.output.onNext(.closeStream)
            }))
            self.output.onNext(.confirmLeave(alert))
        }
    }
    
    private func showStartStreamAlert() {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Start Steam", message: "Are you ready to start the stream?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Start", style: .default, handler: { [weak self] _ in
                self?.streamsProvider.upNodes()
                self?.logSerive.logMessage(topic: .userAction(.startStream))
            }))
            self.output.onNext(.confirmStartStream(alert))
        }
    }
    
    @objc
    private func appWillTerminate() {
        switch streamsProvider.state.value.streamState {
        case .started(_), .waiting, .initiated:
            let semaphore: DispatchSemaphore = DispatchSemaphore(value: 0)
            self.streamsProvider.leaveStream(comletion: {
                semaphore.signal()
            })
            semaphore.wait(timeout: DispatchTime.distantFuture)
        default: break
        }
    }
}

extension StreamsViewModelImpl: StreamsViewModel {
    func setCampaign(_ campaign: Campaign, page: Page) {
        streamsProvider.setCampaign(campaign, page: page)
    }
}

//
//  RTMPStreamService.swift
//  ElisaApp
//
//  Created by alexandr galkin on 19.05.2022.
//

import RxSwift
import Foundation
import HaishinKit
import AVFoundation
import VideoToolbox
import UIKit
import ReplayKit

protocol RTMPStreamManager {
    var events: PublishSubject<RTMPStreamManagerImpl.RTMPStreamManagerEvents> { get }
    var cameraManager: RTMPCameraManager { get }
    func captureDevices(isBackCamera: Bool, disableAdaptiveBitrate: Bool, resolution: String, aVCaptureVideoStabilizationMode: Int)
    func rotateCamera()
    func rotateScreen()
    func publish(rtmpUrl: String, rtmpKey: String)
    func unPublish()
    func stopStreaming()
    func resumeStream()
    func mute()
    func unmute()
    func pauseStream()
}

final class RTMPStreamManagerImpl {
    
    //MARK: - Public vars
    
    var events = PublishSubject<RTMPStreamManagerEvents>()
    let cameraManager: RTMPCameraManager
    
    //MARK: - Substructures
    
    enum BitrateState: String {
        case optimal
        case decreased
    }
    
    enum RTMPStreamManagerEvents {
        case didUpdateLocalStream(localStreamView: MTHKView?)
        case didChangeConnection(state: RTMPConnection.Code)
        case didUserCloseConnection
        case maxReconnectTryReached
        case errorStreamPublishing
        case streamStatistics(statictics: RTMPStatistics)
    }
    
    enum RTMPStreamingConfig {
        case portrait
        case landscape
        
        var hightResolution: (width: Int, height: Int) {
            switch self {
            case .portrait:
                return (1080, 1920)
            case .landscape:
                return (1920, 1080)
            }
        }
        var mediumResolution: (width: Int, height: Int) {
            switch self {
            case .portrait:
                return (720, 1280)
            case .landscape:
                return (1280, 720)
            }
        }
        
    }
    
    // MARK: - Private Variables
    private let logService: LoggingService
    private var bitrateCooldown = false
    private var currentBitrateLevel: BitrateState = .optimal
    private var optimalBitrate: UInt32 = 1024 * 1024 * 6
    private let audioOptimalBitrate: UInt32 = 32 * 1024
    private var streamsClosedByUser: Bool = false
    private var networkDisconnectedTimer: DispatchSourceTimer?
    private let maxRetryCount: Int = 6
    private var disconnectTimerRetryCount: Int = 0
    private var streamIsPublished: Bool = false
    private let audioManager: RTMPAudioManager
    private var rtmpConnection = RTMPConnection()
    private var rtmpStream: RTMPStream?
    private var sharedObject: RTMPSharedObject!
    private var maxFPS: Int = 30
    private var rtmpPath: String = ""
    private var rtmpUrl: String = ""
    var resolution = ""
    // 'Standard' stabilization mode by default
    var aVCaptureVideoStabilizationMode = 1
    private var streamResolutionConfig: RTMPStreamManagerImpl.RTMPStreamingConfig = .portrait {
        didSet {
            guard let device: AVCaptureDevice = cameraManager.state.value.device else {
                return
            }
            
            if(self.resolution == "1080p"){
                optimalBitrate = 1024 * 1024 * 6
            } else{
            optimalBitrate = 1024 * 1024 * 3
            }
            let mode = AVCaptureVideoStabilizationMode(rawValue: self.aVCaptureVideoStabilizationMode) ?? AVCaptureVideoStabilizationMode.standard
            
            if device.supportsSessionPreset(AVCaptureSession.Preset.hd1920x1080) && self.resolution == "1080p"{
                rtmpStream?.frameRate = Float64(maxFPS)
                rtmpStream?.sessionPreset = AVCaptureSession.Preset.hd1920x1080
                rtmpStream?.videoCapture(for: 0)?.preferredVideoStabilizationMode = mode
                
                if let device = AVCaptureDevice.default(for: AVMediaType.video) // or stream.videoCapture(for: 0).device
                {
                    do {
                      try device.lockForConfiguration()
                      device.exposureMode = .continuousAutoExposure
                      device.unlockForConfiguration()
                        
                    } catch let error as NSError {
                      print("while locking device for exposurePointOfInterest: \(error)")
                    }
                }
                
                rtmpStream?.videoSettings = [
                    .width: streamResolutionConfig.hightResolution.width, // video output width
                    .height: streamResolutionConfig.hightResolution.height, // video output height
                    .bitrate: optimalBitrate, // video output bitrate
                    .profileLevel: kVTProfileLevel_H264_Baseline_4_0,
                    .maxKeyFrameIntervalDuration: 2,
                ]
                
            } else {
                rtmpStream?.frameRate = Float64(maxFPS)
                rtmpStream?.sessionPreset = AVCaptureSession.Preset.hd1280x720
                rtmpStream?.videoCapture(for: 0)?.preferredVideoStabilizationMode = mode
                
                if let device = AVCaptureDevice.default(for: AVMediaType.video) // or stream.videoCapture(for: 0).device
                {
                    do {
                      try device.lockForConfiguration()
                      device.exposureMode = .continuousAutoExposure
                      device.unlockForConfiguration()
                        
                    } catch let error as NSError {
                      print("while locking device for exposurePointOfInterest: \(error)")
                    }
                }
                
                rtmpStream?.videoSettings = [
                    .width: streamResolutionConfig.mediumResolution.width, // video output width
                    .height: streamResolutionConfig.mediumResolution.height, // video output height
                    .bitrate: optimalBitrate,//1.5 * 1024 * 1024, // video output bitrate
                    .profileLevel: kVTProfileLevel_H264_Baseline_3_1,
                    .maxKeyFrameIntervalDuration: 2 // key frame / sec
                ]
            }
            
            switch streamResolutionConfig {
            case .portrait:
                rtmpStream?.videoSettings[.scalingMode] = ScalingMode.letterbox
            case .landscape:
                rtmpStream?.videoSettings[.scalingMode] = nil
            }
        }
    }
    
    private lazy var lfView: MTHKView = {
        let view = MTHKView(frame: .zero)
        view.backgroundColor = .black
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    //MARK: - INIT
    
    init(audioManager: RTMPAudioManager, cameraManager: RTMPCameraManager, logService: LoggingService) {
        self.audioManager = audioManager
        self.cameraManager = cameraManager
        self.logService = logService
    }
    
    deinit {
        invalidateTimer()
    }
    
    //MARK: - Private methods
    
    @objc private func rtmpStatusHandler(_ notification: Notification) {
        guard let data: ASObject = Event.from(notification).data as? ASObject, let code: String = data["code"] as? String else {
            return
        }
        NSLog("\nRTMP NOTIFICATION CODE: %@", code)

        switch code {
        case RTMPConnection.Code.connectSuccess.rawValue:
            invalidateTimer()
            if !streamIsPublished {
                let type: RTMPStream.HowToPublish = .live
                rtmpStream?.publish(rtmpPath, type: type)
                events.onNext(.didChangeConnection(state: .connectSuccess))
                logService.logMessage(topic: .streamConnectionState(.connectSuccess))
            }
        case RTMPConnection.Code.connectFailed.rawValue:
            if networkDisconnectedTimer == nil {
                stopStreaming()
                events.onNext(.didChangeConnection(state: .connectFailed))
                logService.logMessage(topic: .streamConnectionState(.connectFailed))
            }
        case RTMPConnection.Code.connectClosed.rawValue:
            invalidateTimer()
            streamIsPublished = false
            events.onNext(.didChangeConnection(state: .connectClosed))
            logService.logMessage(topic: .streamConnectionState(.connectClosed))
            if networkDisconnectedTimer == nil, !streamsClosedByUser {
                startTimer(queue: DispatchQueue.global(qos: .utility))
            }
        case RTMPStream.Code.publishBadName.rawValue:
            events.onNext(.errorStreamPublishing)
            logService.logMessage(topic: .streamState(.publishBadName))
            stopStreaming()
        case RTMPStream.Code.unpublishSuccess.rawValue:
            logService.logMessage(topic: .streamState(.unpublishSuccess))
        case RTMPStream.Code.publishStart.rawValue:
            invalidateTimer()
            streamIsPublished = true
            logService.logMessage(topic: .streamState(.publishStart))
        default:
            break
        }
        
    }
    
    private func invalidateTimer() {
        networkDisconnectedTimer = nil
        disconnectTimerRetryCount = 0
    }
    
    private func startTimer(queue: DispatchQueue) {
        networkDisconnectedTimer = DispatchSource.makeTimerSource(queue: queue)
        
        networkDisconnectedTimer?.setEventHandler { [weak self] in
            self?.disconnectTimerHandler()
        }
        networkDisconnectedTimer?.schedule(deadline: .now(), repeating: .milliseconds(5000))
        networkDisconnectedTimer?.resume()
    }
    
    @objc
    private func disconnectTimerHandler() {
        NSLog("\nRECONNECT %@", "")
        guard disconnectTimerRetryCount <= maxRetryCount else {
            invalidateTimer()
            events.onNext(.maxReconnectTryReached)
            return
        }
        
        resumeStream()
        disconnectTimerRetryCount += 1
    }
}

extension RTMPStreamManagerImpl: RTMPStreamManager {
    func stopStreaming() {
        NSLog("\nSTOP STREAMING %@", "")
        rtmpConnection.removeEventListener(.rtmpStatus, selector: #selector(rtmpStatusHandler), observer: self)
        rtmpStream?.removeEventListener(.rtmpStatus, selector: #selector(rtmpStatusHandler), observer: self)
        rtmpConnection.close()
        rtmpStream?.close()
        streamIsPublished = false
        invalidateTimer()
    }
    
    func resumeStream() {
        if !rtmpConnection.connected {
            publish(rtmpUrl: rtmpUrl, rtmpKey: rtmpPath)
        }
    }
    
    func rotateScreen() {
        switch UIDevice.current.orientation {
        case .landscapeLeft:
            streamResolutionConfig = .landscape
//            rtmpStream?.orientation = .landscapeRight
            rtmpStream?.videoOrientation = .landscapeRight
            logService.logMessage(topic: .userAction(.changeOrientation(.landscape)))
        case .landscapeRight:
            streamResolutionConfig = .landscape
//            rtmpStream?.orientation = .landscapeLeft
            rtmpStream?.videoOrientation = .landscapeLeft
            logService.logMessage(topic: .userAction(.changeOrientation(.landscape)))
        case .portrait, .faceUp, .unknown:
            streamResolutionConfig = .portrait
//            rtmpStream?.orientation = .portrait
            rtmpStream?.videoOrientation = .portrait
            logService.logMessage(topic: .userAction(.changeOrientation(.portrait)))
        @unknown default:
            break
        }
    }
    
    func rotateCamera() {
        let position: AVCaptureDevice.Position = cameraManager.state.value.currentPosition == .back ? .front : .back
        
        cameraManager.state.update(\.currentPosition, to: position)
//        cameraManager.state.update(\.device, to: DeviceUtil.device(withPosition: position))
        cameraManager.state.update(\.device, to: RTMPCameraManagerImpl.RTMPCameraManagerState(currentPosition: .front).device)
        
          rtmpStream?.attachCamera(AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position)) { error in
            NSLog(error.localizedDescription)
        }
        
        DispatchQueue.global(qos: .userInteractive).asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.lfView.isMirrored = position == .back ? false : true
        }
        logService.logMessage(topic: .userAction(.switchCamera( position == .back ? .back : .front)))
    }
    
    func captureDevices(isBackCamera: Bool, disableAdaptiveBitrate: Bool, resolution : String, aVCaptureVideoStabilizationMode: Int) {
        guard let device: AVCaptureDevice = cameraManager.state.value.device else {
            return
        }
        NSLog("\naVCaptureVideoStabilizationMode : %@", String(aVCaptureVideoStabilizationMode))
        self.resolution = resolution
        self.aVCaptureVideoStabilizationMode = aVCaptureVideoStabilizationMode
        streamsClosedByUser = false
        
        rtmpStream = RTMPStream(connection: rtmpConnection)
        if !disableAdaptiveBitrate {
            rtmpStream?.delegate = self
        }
        rotateScreen()
        
//        rtmpStream?.captureSettings[.isVideoMirrored] = false
        rtmpStream?.videoCapture(for: 0)?.isVideoMirrored = false
        
        if isBackCamera {
            cameraManager.state.update(\.currentPosition, to: .back)
        } else {
            cameraManager.state.update(\.currentPosition, to: .front)
        }
        
        
        rtmpStream?.audioSettings = [
//            .muted: false,
            .bitrate: 32 * 1024,
            .sampleRate: 44_100,
        ]
        
        
        rtmpStream?.attachAudio(AVCaptureDevice.default(for: .audio)) { error in
            NSLog("\nWarn : %@", error.localizedDescription)
        }
        rtmpStream?.attachCamera(device) { error in
            NSLog("\nWarn : %@", error.localizedDescription)
        }

        lfView.videoGravity = .resizeAspect
        lfView.isMirrored = !isBackCamera
        lfView.attachStream(rtmpStream)
        events.onNext(.didUpdateLocalStream(localStreamView: lfView))
        
    }
    
    func publish(rtmpUrl: String, rtmpKey: String) {
        rtmpConnection.removeEventListener(.rtmpStatus, selector: #selector(rtmpStatusHandler), observer: self)
        rtmpStream?.removeEventListener(.rtmpStatus, selector: #selector(rtmpStatusHandler), observer: self)
        rtmpConnection.addEventListener(.rtmpStatus, selector: #selector(rtmpStatusHandler), observer: self)
        rtmpStream?.addEventListener(.rtmpStatus, selector: #selector(rtmpStatusHandler), observer: self)
        rtmpPath = rtmpKey
        self.rtmpUrl = rtmpUrl
        rtmpConnection.connect(rtmpUrl)
    }
    
    func unPublish() {
        streamsClosedByUser = true
        stopStreaming()
        events.onNext(.didUserCloseConnection)
    }
    
    func mute() {
        rtmpStream?.hasAudio = false
    }
    
    func unmute() {
        rtmpStream?.hasAudio = true
    }
    
    func pauseStream() {
//        rtmpStream?.paused = true
    }
}

extension RTMPStreamManagerImpl {
    internal func adjustBitrate (decrease: Bool, stream: RTMPStream) {
        guard !bitrateCooldown else { return }
        let currentBitrate = rtmpStream?.videoSettings[.bitrate] as! UInt32
        
        NSLog("\nCurrentBitrate: %d%@%@%@%@%@", currentBitrate,
              "\nBitrateCooldown \(bitrateCooldown.description)",
              "\nBitrateDecrease \(decrease.description)",
              "\nBitrateOutBytesPerSecond \(rtmpConnection.currentBytesOutPerSecond)",
              "\nBitrateInBytesPerSecond \(rtmpConnection.currentBytesInPerSecond)",
              "\nBitrateTotalBytesPerSecond \(rtmpConnection.currentBytesOutPerSecond + rtmpConnection.currentBytesInPerSecond)")
        
        let time = 5.0
        var newBitrate: UInt32 = 0
        let bitratePercent = Float(currentBitrate) / Float(optimalBitrate) * 100
        let minimalBitratePercent: Float = 50.0
                
        switch currentBitrateLevel {
        case .optimal:
            guard decrease else {
                #if DEV || TEST
                events.onNext(.streamStatistics(statictics: RTMPStatistics(optimalBitrate: optimalBitrate,
                                                                           currBitrate: currentBitrate,
                                                                           outBytesPerSecond: rtmpConnection.currentBytesOutPerSecond,
                                                                           inBytesPerSecond: rtmpConnection.currentBytesInPerSecond,
                                                                           bitrateTotalBytesPerSecond: rtmpConnection.currentBytesOutPerSecond
                                                                                                     + rtmpConnection.currentBytesInPerSecond,
                                                                           newBitrate: currentBitrate,
//                                                                           captureFPS: stream.captureSettings[.fps] as! Float64
                                                                           captureFPS: Float64(stream.currentFPS)
                                                                          )
                            )
                )
                #endif
                return
            }
            newBitrate = UInt32(Float(optimalBitrate) * 0.8)
            currentBitrateLevel = .decreased
        case .decreased:
            if decrease {
                
                guard bitratePercent > minimalBitratePercent else {
                    newBitrate = UInt32(Float(optimalBitrate) * 0.5)
                    break
                }
                
                newBitrate = UInt32(Float(currentBitrate) * 0.95)
                let bitratePercent = Float(newBitrate) / Float(optimalBitrate) * 100
                if bitratePercent < minimalBitratePercent {
                    newBitrate = UInt32(Float(optimalBitrate) * 0.5)
                }
            } else {
                newBitrate = UInt32(Float(currentBitrate) * 1.1)
                if newBitrate >= optimalBitrate {
                    newBitrate = optimalBitrate
                    currentBitrateLevel = .optimal
                }
            }
        }
        logService.logMessage(topic: .bitrate(bitrateForLog(newBitrate)))
        rtmpStream?.videoSettings[.bitrate] = newBitrate
        
        NSLog("\nHaishin newBitrate: %ld", newBitrate)
        NSLog("\nHaishin Bitrate Decrease: %@ newLevel: %@", decrease.description, currentBitrateLevel.rawValue)
        
        #if DEV || TEST
        events.onNext(.streamStatistics(statictics: RTMPStatistics(optimalBitrate: optimalBitrate,
                                                                   currBitrate: currentBitrate,
                                                                   outBytesPerSecond: rtmpConnection.currentBytesOutPerSecond,
                                                                   inBytesPerSecond: rtmpConnection.currentBytesInPerSecond,
                                                                   bitrateTotalBytesPerSecond: rtmpConnection.currentBytesOutPerSecond
                                                                                             + rtmpConnection.currentBytesInPerSecond,
                                                                   newBitrate: newBitrate,
//                                                                   captureFPS: stream.captureSettings[.fps] as! Float64
                                                                   captureFPS: Float64(stream.currentFPS)
                                                                  )
                                        )
                     )
        #endif
        bitrateCooldown = true
        DispatchQueue.global().asyncAfter(deadline: .now() + time) {
            self.bitrateCooldown = false
        }
        
    }
    
    private func bitrateForLog(_ bitrate: UInt32) -> String {
        let newBitrate = Double(bitrate) / (1024 * 1024)
        let decimal = String(format: "%.2f", newBitrate.truncatingRemainder(dividingBy: 1))
        let integer = Int(newBitrate)
        return "\(integer).\(decimal.suffix(2))"
    }
}

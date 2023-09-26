//
//  StreamsEvent.swift
//  ElisaApp
//
//  Created by Mikhail Sein on 22.03.2022.
//

import UIKit
import AVFoundation

struct StreamsInput {
    let campaign: Campaign?
    let cameraGranted: Bool?
    let micGranted: Bool?
    let localStreamView: UIView?
	let localStreamLayer: AVCaptureVideoPreviewLayer?
    let streamState: StreamsProviderState.StreamState
    var isLoading: Bool = false
    var overlayUrl: URL?
    var streamError: StreamsProviderState.StreamStartError?
    var shouldReloadOverlay: Bool
    let statistic: String?
    let micState: MicState
}

enum StreamsOutput {
    case closeStream
    case settingsPressed
    case confirmLeave(UIAlertController)
    case confirmStartStream(UIAlertController)
    case showFailed
}

enum StreamsEvent {
    case viewDidAppear
    case backPressed
    case settingsPressed
    case startPressed
    case endPressed
    case camSwitchPressed
    case brightnessChanged(Double)
    case rotationEvent
    case appDidEnterToBackground
    case appDidBecomeActive
    case viewDidDisAppear
    case micButtonTapped
}

//
//  RTMPCameraManager.swift
//  ElisaApp
//
//  Created by alexandr galkin on 23.05.2022.
//

import Foundation
import RxRelay
import AVFoundation

protocol RTMPCameraManager: AnyObject {
    func changeExposure(value: Double) throws
    func changeExposureMode(_ mode: AVCaptureDevice.ExposureMode) throws
    var state: BehaviorRelay<RTMPCameraManagerImpl.RTMPCameraManagerState> { get }
}

final class RTMPCameraManagerImpl: RTMPCameraManager {
    struct RTMPCameraManagerState: UpdatableStruct {
        var device: AVCaptureDevice?
        var currentPosition: AVCaptureDevice.Position = .front
    }
    public let state: BehaviorRelay<RTMPCameraManagerState>
    
    init() {
//        state = BehaviorRelay<RTMPCameraManagerState>(value: RTMPCameraManagerState(device: DeviceUtil.device(withPosition: .front)))
        
        state = BehaviorRelay<RTMPCameraManagerState>(
            value: RTMPCameraManagerState(
                device: AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
            )
        )
        
    }
    
    deinit {
//        state.update(\.device, to: DeviceUtil.device(withPosition: .front))
        state.update(\.device, to: AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front))
        try? changeExposure(value: 0.5)
//        state.update(\.device, to: DeviceUtil.device(withPosition: .back))
        state.update(\.device, to: AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back))
        try? changeExposure(value: 0.5)
    }
    
    func changeExposure(value: Double) throws {
        guard let device = state.value.device else { return }
        
        try device.lockForConfiguration()
        device.exposureMode = .continuousAutoExposure
        let exposure: Float = Float(Double(min(device.maxExposureTargetBias, abs(device.minExposureTargetBias))) * 2.0 * (value - 0.5))
        device.setExposureTargetBias(exposure) { _ in
            device.unlockForConfiguration()
        }
    }
    
    func changeExposureMode(_ mode: AVCaptureDevice.ExposureMode) throws {
        guard let device = state.value.device else { return }

        try device.lockForConfiguration()
        device.exposureMode = mode
        device.unlockForConfiguration()
    }
}

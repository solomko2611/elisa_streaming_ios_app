//
//  PermissionManager.swift
//  Nucleus
//
//  Created by Mikhail Sein on 15.11.2021.
//

import AVKit
import RxSwift
import RxRelay

protocol PermissionManager {
    var state: BehaviorRelay<PermissionManagerImpl.PermissionManagerState> { get }
    
    func requestCapturePermission()
    func requestRecordPermission()
    func getNotificationsPermission()
}

final class PermissionManagerImpl {
    
    // MARK: - Public Properties
    
    struct PermissionManagerState: UpdatableStruct {
        var capturePermissionStatus: AVAuthorizationStatus = .notDetermined
        var recordPermissionStatus: Bool?
        var notificationPermissionStatus: UNNotificationSettings?
    }
    
    let state = BehaviorRelay<PermissionManagerState>(value: PermissionManagerState())
}

extension PermissionManagerImpl: PermissionManager {
    func requestCapturePermission() {
        let authorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        switch authorizationStatus {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                self.state.update(\.capturePermissionStatus, to: granted ? .authorized : .denied)
            }
        default:
            state.update(\.capturePermissionStatus, to: authorizationStatus)
        }
    }
    
    func requestRecordPermission() {
        AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
            self?.state.update(\.recordPermissionStatus, to: granted)
        }
    }
    
    func getNotificationsPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            self?.state.update(\.notificationPermissionStatus, to: settings)
        }
    }
}

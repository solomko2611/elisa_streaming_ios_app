//
//  AudioManager.swift
//  Stream
//
//  Created by Mikhail Sein on 11.03.2021.
//

import AVFoundation

public protocol RTMPAudioManager {
    func setOutputPort(_ portOverride: AVAudioSession.PortOverride) throws
}

public final class RTMPAudioManagerImpl {
    
    // MARK: - Private Properties
    
    private let options: AVAudioSession.CategoryOptions
    private let mode: AVAudioSession.Mode
    private lazy var session = AVAudioSession()
    
    // MARK: - Initializer
    
    public init() {
        self.options = [.defaultToSpeaker, .allowBluetooth, .allowBluetoothA2DP, .allowAirPlay, .mixWithOthers]
        self.mode = .default
        
        configureObservables()
        try? activate()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Private Methods
    
    private func activate() throws {
        try session.setCategory(.playAndRecord, options: options)
        try session.setMode(mode)
        try session.setActive(true)
    }
    
    private func configureObservables() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleRouteChange),
                                               name: AVAudioSession.routeChangeNotification,
                                               object: nil)
    }
    
    @objc private func handleRouteChange(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else {
                  return
              }
        
        switch reason {
        case .newDeviceAvailable, .oldDeviceUnavailable, .categoryChange:
            let headphonesConnected = hasHeadphones(in: session.currentRoute)
            let isHFP = isHFPDevice(in: session.currentRoute)
            
            if headphonesConnected {
                try? setOutputPort(headphonesConnected ? .none : .speaker)
            }
            
            if isHFP {
                try? setupHFPIO()
            }
        default:
            return
        }
    }
    
    private func hasHeadphones(in routeDescription: AVAudioSessionRouteDescription) -> Bool {
        return !routeDescription.outputs.filter({
            $0.portType == .headphones ||
            $0.portType == .bluetoothA2DP
        }).isEmpty
    }
    
    private func isHFPDevice(in routeDescription: AVAudioSessionRouteDescription) -> Bool {
        return !routeDescription.outputs.filter { $0.portType == .bluetoothHFP }.isEmpty
    }
}

extension RTMPAudioManagerImpl: RTMPAudioManager {
    public func setOutputPort(_ portOverride: AVAudioSession.PortOverride) throws {
        try session.overrideOutputAudioPort(portOverride)
    }
    
    public func setupHFPIO() throws {
        try session.overrideOutputAudioPort(.none)
        if let desc = session.availableInputs?.first(where: { $0.portType == .bluetoothHFP }) {
            try session.setPreferredInput(desc)
        }
    }
}

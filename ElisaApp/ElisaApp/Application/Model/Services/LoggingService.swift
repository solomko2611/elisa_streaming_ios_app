//
//  LoggingService.swift
//  ElisaApp
//
//  Created by alexandr galkin on 27.01.2023.
//

import Foundation
import UIKit

protocol LoggingService {
    func logMessage(topic: TopicLog)
}

final class LoggingServiceImpl {
    private let socketManager: SocketManager
    
    init(socketManager: SocketManager) {
        self.socketManager = socketManager
    }
    
    private func sendMessage(message: String, logLevel: LogLevel, topic: TopicLog) {
        let os = "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)"
        let device = UIDevice.modelName
        let timestamp = Int64((Date().timeIntervalSince1970 * 1000.0).rounded())
        let loggingModel = LoggingModel(platform: .ios,
                                        osVersion: os,
                                        deviceModel: device,
                                        logLevel: logLevel,
                                        topic: topic,
                                        message: message,
                                        timestamp: timestamp)
        socketManager.emit("v1:logs:new", items: loggingModel.dictionary)
    }
}

extension LoggingServiceImpl: LoggingService {
    func logMessage(topic: TopicLog) {
        var logMessage = ""
        var loggingLevel = topic.logLevel
        
        switch topic {
        case .bitrate(let bitrate):
            logMessage = "Dynamic video bitrate updated to \(bitrate) mbit/s"
        case .socketInput(let event):
            logMessage = "\(event) socket message received"
        case .socketOutput(let event, let parameters):
            let paramsString = (parameters.map { key, value in
                return "\(key) = \(value)"
            } as Array).joined(separator: "; ")
            logMessage = "\(event) socket message emitted: \(paramsString)"
        case .streamState(let streamStateLog):
            loggingLevel = streamStateLog.logLevel
            logMessage = "Stream state: \(streamStateLog.rawValue)"
        case .streamConnectionState(let streamConnectionStateLog):
            loggingLevel = streamConnectionStateLog.logLevel
            logMessage = "Stream connection state: \(streamConnectionStateLog.rawValue)"
        case .campaingReady(let id, let status):
            logMessage = "Campaign \(id), preparedness checked: result = \(status.description)"
        case .userAction(let userActionLog):
            loggingLevel = userActionLog.logLevel
            switch userActionLog {
            case .startStream:
                logMessage = "User action: start_stream"
            case .closeStream:
                logMessage = "User action: close_stream"
            case .collapsApp:
                logMessage = "User action: collaps_app"
            case .expandApp:
                logMessage = "User action: expand_app"
            case .changeOrientation(let orientation):
                logMessage = "User action: change_orientation \(orientation.rawValue)"
            case .switchCamera(let camera):
                logMessage = "User action: switch_camera \(camera.rawValue)"
            case .switchMic(let mic):
                logMessage = "User action: switch_mic \(mic.rawValue)"
            }
        }
        
        sendMessage(message: logMessage, logLevel: loggingLevel, topic: topic)
    }
}

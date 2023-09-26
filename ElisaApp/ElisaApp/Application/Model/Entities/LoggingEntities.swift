//
//  LoggingEntities.swift
//  ElisaApp
//
//  Created by alexandr galkin on 27.01.2023.
//

import Foundation

protocol LoggingLevelProtocol: Encodable {
    var logLevel: LogLevel { get }
}

extension LoggingLevelProtocol {
    var logLevel: LogLevel {
        return .info
    }
}

enum LogLevel: String, Encodable {
    case info, warning, error
}

enum PlatformLog: String, Encodable {
    case ios
}

enum TopicLog: LoggingLevelProtocol, Encodable {
    case bitrate(String)
    case socketInput(String)
    case socketOutput(String, [String: String])
    case streamState(StreamStateLog)
    case streamConnectionState(StreamConnectionStateLog)
    case campaingReady(String, Bool)
    case userAction(UserActionLog)
}

enum UserActionLog: LoggingLevelProtocol, Encodable {
    enum Camera: String, Encodable {
        case back
        case front
    }
    
    enum Mic: String, Encodable {
        case mute
        case unmute
    }
    
    enum Orientation: String, Encodable {
        case portrait
        case landscape
    }
    
    case startStream
    case closeStream
    case collapsApp
    case expandApp
    case changeOrientation(Orientation)
    case switchCamera(Camera)
    case switchMic(Mic)
}

enum StreamStateLog: String, LoggingLevelProtocol, Encodable {
    case publishBadName
    case unpublishSuccess
    case publishStart
    
    var logLevel: LogLevel {
        switch self {
        case .publishBadName:
            return .error
        case .publishStart, .unpublishSuccess:
            return .info
        }
    }
}

enum StreamConnectionStateLog: String, LoggingLevelProtocol, Encodable {
    case connectSuccess
    case connectFailed
    case connectClosed
    
    var logLevel: LogLevel {
        switch self {
        case .connectSuccess, .connectClosed:
            return .info
        case .connectFailed:
            return .error
        }
    }
}

struct LoggingModel: Encodable {
    let platform: PlatformLog
    let osVersion: String
    let deviceModel: String
    let logLevel: LogLevel
    let topic: TopicLog
    let message: String
    let timestamp: Int64
    
    var dictionary: [String: String] {
        return ["platform" : platform.rawValue,
                "os_version" : osVersion,
                "device_model" : deviceModel,
                "log_level" : logLevel.rawValue,
                "topic" : (try? JSONSerialization
                                .jsonObject(with: topicData ?? Data()) as? [String: Any])?
                                .keys
                                .first ?? "",
                "message" : message,
                "timestamp" : "\(timestamp)"]
    }
    
    var topicData: Data? {
        return try? JSONEncoder().encode(topic)
    }
}

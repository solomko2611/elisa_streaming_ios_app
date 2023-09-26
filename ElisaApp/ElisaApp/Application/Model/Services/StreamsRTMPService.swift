//
//  StreamsRTMPService.swift
//  ElisaApp
//
//  Created by alexandr galkin on 20.05.2022.
//

import Foundation
import UIKit

protocol StreamsRTMPService {
    func  emitRTMPCredetnials(witdh: Int,
                            height: Int,
                            elisaToken: String,
                            facebookId: String)
    func closeStream(completion: @escaping (Response<NetworkSuccessDeleteStream>) -> Void)
    func checkScheduledSession(campaignId: String,
                               completion: @escaping (Response<ScheduledSessionNetworkResponse>) -> Void)
    func connectSocket(campaignId: String)
    func disconnectSocket()
    func upNodes()
}

final class StreamsRTMPServiceImpl {
    
    // MARK: - Private Properties
    
    private let networkManager: NetworkManager
    private let socketService: SocketManager
    private let logService: LoggingService
    
    // MARK: - Initializer
    
    init(networkManager: NetworkManager, socketManager: SocketManager, logService: LoggingService) {
        self.networkManager = networkManager
        self.socketService = socketManager
        self.logService = logService
    }
}

extension StreamsRTMPServiceImpl: StreamsRTMPService {
    
    enum SocketEmits: String {
        case stop = "v1:streaming:stop"
        case inits = "v1:streaming:init"
        case upNodes = "v1:nodes:up"
    }
    
    func closeStream(completion: @escaping (Response<NetworkSuccessDeleteStream>) -> Void) {
        socketService.emit(SocketEmits.stop.rawValue, items: [:])
        logService.logMessage(topic: .socketOutput(SocketEmits.stop.rawValue, [:]))
        completion(Response.success(NetworkSuccessDeleteStream()))
    }
    
    func emitRTMPCredetnials(witdh: Int,
                            height: Int,
                            elisaToken: String,
                            facebookId: String) {
        logService.logMessage(topic: .socketOutput(SocketEmits.inits.rawValue, ["width": "\(witdh)",
                                                                                "height": "\(height)",
                                                                                "elisaToken": elisaToken,
                                                                                "facebookId": facebookId]))
        socketService.emit(SocketEmits.inits.rawValue, items: ["width": witdh,
                                                        "height": height,
                                                        "elisaToken": elisaToken,
                                                        "facebookId": facebookId])
    }
    
    func checkScheduledSession(campaignId: String,
                               completion: @escaping (Response<ScheduledSessionNetworkResponse>) -> Void) {
        let request = NetworkRequest(path: "sessions/\(campaignId)",
                                     method: .get,
                                     host: .api)
        networkManager.execute(request: request) { (response: Response<ScheduledSessionNetworkResponse>) in
            completion(response)
        }
    }
    
    func connectSocket(campaignId: String) {
        socketService.connect(campaignId: campaignId)
    }
    
    func disconnectSocket() {
        socketService.disconnect()
    }
    
    func upNodes() {
        socketService.emit(SocketEmits.upNodes.rawValue)
        logService.logMessage(topic: .socketOutput(SocketEmits.upNodes.rawValue, [:]))
        socketService.subscribeOnce(event: SocketEvent.streamStopped.rawValue)
        socketService.subscribeOnce(event: SocketEvent.nodesReady.rawValue)
        socketService.subscribeOnce(event: SocketEvent.streamInited.rawValue)
    }
}

//
//  SocketManager.swift
//  Nucleus
//
//  Created by Mikhail Sein on 26.04.2021.
//

import Foundation
import SocketIO
import RxSwift

protocol SocketManager {
    var onEvent: PublishSubject<(event: SocketEvent, data: [Any]?)> { get }
    
    /// Connect to the server
    func connect(campaignId: String)
    /// Disconnect from the server
    func disconnect()
    /// Emit data
    func emit(_ event: String, items: SocketData...)
    /// Subscribe once
    func subscribeOnce(event: String)
}

final class SocketManagerImpl {
    
    // MARK: - Private Properties
    
    private let queue = DispatchQueue(
        label: String(format: "%@.socketmanager-queue", Bundle.main.bundleIdentifier!),
        qos: .utility
    )
    private let manager: SocketIO.SocketManager
    private let socket: SocketIO.SocketIOClient
    private let storage: UserProperties
    
    // MARK: - Public Properties
    
    let onEvent = PublishSubject<(event: SocketEvent, data: [Any]?)>()
    
    // MARK: - Initializer
    
    init(environmentManager: EnvironmentManager, storage: UserProperties) {
        guard let url = URL(string: environmentManager.socketURL()) else {
            fatalError("Invalid Socket URL")
        }
        
        print("CONNECTING SOCKET URL: \(url)")
        
        self.storage = storage
        
        manager = SocketIO.SocketManager(
            socketURL: url
        )
        socket = manager.defaultSocket
        
        configureObservables()
    }
    
    // MARK: - Private Methods
    
    private func configureObservables() {
        socket.on(SocketEvent.statusChange.rawValue) { [weak self] items, _ in
            self?.socketEventHandler(SocketEvent.statusChange.rawValue, items)
        }
        
        socket.on(SocketEvent.socketError.rawValue) { [weak self] items, _ in
            self?.socketEventHandler(SocketEvent.socketError.rawValue, items)
        }
    }
    
    private func socketEventHandler(_ event: String, _ items: [Any]?) {
        if let socketEvent = SocketEvent(rawValue: event) {
            onEvent.onNext((socketEvent, items))
        }
        print(Date(), "RECEIVE", event, "with", items ?? [])
    }
}

extension SocketManagerImpl: SocketManager {
    func connect(campaignId: String) {
        let userId = UUID().uuidString
        queue.async {
            guard !self.manager.status.active else {
                return
            }
            
            self.manager.config = [
                .reconnects(true),
                .reconnectAttempts(-1),
                .forceWebsockets(true),
                .secure(true),
                .connectParams([
                    "campaignId": campaignId,
                    "userUid": userId
                    
                ])
            ]
            self.socket.connect()
        }
    }
    
    func disconnect() {
        queue.async {
            guard self.manager.status.active else {
                return
            }

            self.manager.disconnect()
        }
    }
    
    func emit(_ event: String, items: SocketData...) {
        print(Date(), "EMIT", event, "with", items)
        socket.emit(event, items, completion: nil)
    }
    
    func subscribeOnce(event: String) {
        socket.once(event, callback: { [weak self] items, _  in
            self?.socketEventHandler(event, items)
        })
    }
}

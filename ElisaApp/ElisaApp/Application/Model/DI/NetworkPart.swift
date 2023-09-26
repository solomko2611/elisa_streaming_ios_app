//
//  NetworkPart.swift
//  ElisaApp
//
//  Created by Dmitriy.K on 02.03.2022.
//

import Foundation
import DITranquillity

class NetworkPart: DIPart {
    static func load(container: DIContainer) {
        container.register(RequestInterceptorImpl.init).as(RequestInterceptor.self).lifetime(.perRun(.weak))
        container.register(NetworkManagerImpl.init).as(NetworkManager.self).lifetime(.perRun(.weak))
    }
}

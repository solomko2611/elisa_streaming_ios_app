//
//  ServicesPart.swift
//  ElisaApp
//
//  Created by Dmitriy.K on 02.03.2022.
//

import DITranquillity

final class ServicesPart: DIPart {
    static func load(container: DIContainer) {
        // MARK: - Auth
        container.register(AuthServiceImpl.init).as(AuthService.self).lifetime(.perRun(.weak))
        container.register(CollectionServiceImpl.init).as(CollectionService.self).lifetime(.perContainer(.weak))
    }
}

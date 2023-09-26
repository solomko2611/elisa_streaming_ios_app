//
//  BasePart.swift
//  ElisaApp
//
//  Created by Dmitriy.K on 02.03.2022.
//

import DITranquillity

class BasePart: DIPart {
    static func load(container: DIContainer) {
        container.register(UserDefaultsManagerImpl.init).as(UserDefaultsManager.self).lifetime(.perRun(.weak))
        container.register(KeychainManagerImpl.init).as(KeychainManager.self).lifetime(.perRun(.weak))
        container.register(UserPropertiesImpl.init).as(UserProperties.self).lifetime(.perRun(.weak))
        container.register(EnvironmentManagerImpl.init).as(EnvironmentManager.self).lifetime(.perRun(.weak))
        container.register(PermissionManagerImpl.init).as(PermissionManager.self).lifetime(.perRun(.weak))
    }
}

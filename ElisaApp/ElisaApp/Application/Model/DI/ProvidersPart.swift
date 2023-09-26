//
//  ProvidersPart.swift
//  ElisaApp
//
//  Created by Dmitriy.K on 04.03.2022.
//

import DITranquillity

class ProvidersPart: DIPart {
    
    static func load(container: DIContainer) {
        // MARK: - Auth
        container.register(AuthProviderImpl.init).as(AuthProvider.self).lifetime(.objectGraph)
    }
}

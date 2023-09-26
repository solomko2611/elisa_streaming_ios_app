//
//  EnvironmentManager.swift
//  ElisaApp
//
//  Created by Dmitriy.K on 02.03.2022.
//

import Foundation

protocol EnvironmentManager {
    func serverApiURL() -> String
    func socketURL() -> String
    func setDynamicSocketURL(url: String)
}

final class EnvironmentManagerImpl {
    
    // MARK: - Private Properties
    
    private let environment: Environment
    
    private var dynamicSocketURL: String?
    
    // MARK: - Initializer
    
    init() {
        #if DEV
        environment = .develop
        #elseif TEST
        environment = .testing
        #elseif DEMO
        environment = .demo
        #elseif PROD
        environment = .prod
        #elseif RELEASE
        environment = .release
        #else
        #error("Should specify environment compiler flag")
        #endif
    }
}

extension EnvironmentManagerImpl: EnvironmentManager {
    func serverApiURL() -> String {
        environment.apiURL
    }
    
    func socketURL() -> String {
        if let dynamicUrl = dynamicSocketURL {
            return dynamicUrl
        }
        return environment.socketURL
    }
    
    func setDynamicSocketURL(url: String) {
        dynamicSocketURL = url
    }
}

// MARK: - Environment

private enum Environment {
    case develop
    case testing
    case demo
    case prod
    case release
    
    var apiURL: String {
        switch self {
        case .develop: return "https://europe-west1-app-elisa-io.cloudfunctions.net/streamAPI"
        case .testing: return "https://europe-west1-app-elisa-io.cloudfunctions.net/streamAPI"
        case .demo: return "https://europe-west1-app-elisa-io.cloudfunctions.net/streamAPI"
        case .prod: return "https://europe-west1-app-elisa-io.cloudfunctions.net/streamAPI"
        case .release: return "https://europe-west1-app-elisa-io.cloudfunctions.net/streamAPI"
        }
    }
    
    var socketURL: String {
        switch self {
        case .develop: return "https://dev-elisa.staging.forasoft.com"
        case .testing: return "https://test-elisa.staging.forasoft.com"
        case .demo: return "https://demo-elisa.staging.forasoft.com"
        case .prod: return ""
        case .release: return ""
        }
    }
}

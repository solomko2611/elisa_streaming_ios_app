//
//  UserProperties.swift
//  ElisaApp
//
//  Created by Dmitriy.K on 04.03.2022.
//

import Foundation
import RxSwift

protocol UserProperties {
    var token: String? { get }
    var disableAdaptiveBitrate: Bool? { get }
    
    func isLoggedIn() -> Bool
    func update(with response: LoginResponse)
    func clear(with reason: UserPropertiesImpl.LogoutReason)
}

final class UserPropertiesImpl {
    
    // MARK: - Public Properties
    private(set) var token: String?
    private(set) var disableAdaptiveBitrate: Bool?
    
    enum LogoutReason {
        case manual
        case tokenExpired
    }
    
    // MARK: - Initializer
    
    init(keychainManager: KeychainManager) {
        if let data: Data = keychainManager.get(key: .authTokens), let tokens = try? JSONDecoder().decode(LoginResponse.self, from: data) {
            token = tokens.token
            disableAdaptiveBitrate = tokens.disableAdaptiveBitrate
        } else {
            token = nil
            disableAdaptiveBitrate = nil
        }
    }
}

extension UserPropertiesImpl: UserProperties {
    func isLoggedIn() -> Bool {
        token != nil
    }
    
    func update(with response: LoginResponse) {
        token = response.token
        disableAdaptiveBitrate = response.disableAdaptiveBitrate
    }
    
    func clear(with reason: LogoutReason) {
        token = nil
        disableAdaptiveBitrate = nil
    }
}

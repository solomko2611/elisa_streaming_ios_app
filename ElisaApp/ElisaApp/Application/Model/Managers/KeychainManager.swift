//
//  KeychainManager.swift
//  ElisaApp
//
//  Created by Dmitriy.K on 02.03.2022.
//

import Foundation
import KeychainSwift

protocol KeychainManager {
    /// Saving object into keychain for given key
    /// - Parameters:
    ///   - object: string
    ///   - key: string
    func set(object: String, key: KeychainManagerImpl.KeychainKeys)
    
    /// Saving object into keychain for given key
    /// - Parameters:
    ///   - object: string
    ///   - key: string
    func set(object: Data, key: KeychainManagerImpl.KeychainKeys)
    
    /// Getting object storing into keychain for given key
    /// - Parameter key: string
    /// - Returns: string value if exists
    func get(key: KeychainManagerImpl.KeychainKeys) -> String?
    
    /// Getting object storing into keychain for given key
    /// - Parameter key: string
    /// - Returns: string value if exists
    func get(key: KeychainManagerImpl.KeychainKeys) -> Data?
    
    /// Removing object storing into keychain (if exists) for given key
    /// - Parameter key: string
    func remove(key: KeychainManagerImpl.KeychainKeys)
}

final class KeychainManagerImpl {
    
    enum KeychainKeys: String {
        case authTokens, pushToken
    }
    
    // MARK: - Private Properties
    
    private lazy var keychain = KeychainSwift()
    private lazy var queue = DispatchQueue(
        label: String(format: "%@.keychain-queue", Bundle.main.bundleIdentifier!),
        qos: .background,
        attributes: .concurrent
    )
    
    // MARK: - Initializer
    
    init(userDefaultsManager: UserDefaultsManager) {
        clearIfNeeded(with: userDefaultsManager)
    }
    
    // MARK: - Private Properties
    
    private func clearIfNeeded(with userDefaultsManager: UserDefaultsManager) {
        if !userDefaultsManager.get(key: .firstLaunch) {
            userDefaultsManager.set(true, key: .firstLaunch)
            queue.async(flags: .barrier) {
                self.keychain.clear()
            }
        }
    }
}

extension KeychainManagerImpl: KeychainManager {
    func set(object: String, key: KeychainKeys) {
        queue.async(flags: .barrier) {
            self.keychain.set(object, forKey: key.rawValue)
        }
    }
    
    func set(object: Data, key: KeychainKeys) {
        queue.async(flags: .barrier) {
            self.keychain.set(object, forKey: key.rawValue)
        }
    }
    
    func get(key: KeychainKeys) -> String? {
        queue.sync {
            keychain.get(key.rawValue)
        }
    }
    
    func get(key: KeychainKeys) -> Data? {
        queue.sync {
            keychain.getData(key.rawValue)
        }
    }
    
    func remove(key: KeychainKeys) {
        queue.async(flags: .barrier) {
            self.keychain.delete(key.rawValue)
        }
    }
}

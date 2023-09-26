//
//  UserDefaultsManager.swift
//  ElisaApp
//
//  Created by Dmitriy.K on 04.03.2022.
//

import Foundation
import KeychainSwift

protocol UserDefaultsManager: AnyObject {
    /// Saving object into user default for given key
    /// - Parameters:
    ///   - object: Any (optional)
    ///   - key: string
    func set(_ object: Any?, key: UserDefaultsManagerImpl.Keys)
    
    /// Getting object storing into user defaults for given key
    /// - Parameter key: string
    /// - Returns: generic value if exists
    func get<T>(key: UserDefaultsManagerImpl.Keys) -> T?
    
    /// Getting bool value storing into user defaults for given key
    /// - Parameter key: string
    /// - Returns: Bool value if exists or false
    func get(key: UserDefaultsManagerImpl.Keys) -> Bool
    func removeValue(for key: UserDefaultsManagerImpl.Keys)
}

final class UserDefaultsManagerImpl {
    
    enum Keys: String {
        case firstLaunch
        case saveTimeKey
        case backendURL
    }
    
    // MARK: - Private Properties
    
    private lazy var userDefaults = UserDefaults.standard
    private lazy var queue = DispatchQueue(
        label: String(format: "%@.userdefaults-queue", Bundle.main.bundleIdentifier!),
        qos: .background,
        attributes: .concurrent
    )
    
    // MARK: - Initializer
    
    init() {}
}

extension UserDefaultsManagerImpl: UserDefaultsManager {
    func set(_ object: Any?, key: Keys) {
        queue.async(flags: .barrier) {
            self.userDefaults.set(object, forKey: key.rawValue)
        }
    }
    
    func get<T>(key: Keys) -> T? {
        queue.sync {
            userDefaults.object(forKey: key.rawValue) as? T
        }
    }
    
    func get(key: Keys) -> Bool {
        queue.sync {
            userDefaults.bool(forKey: key.rawValue)
        }
    }
    
    func removeValue(for key: Keys) {
        queue.sync {
            userDefaults.removeObject(forKey: key.rawValue)
        }
    }
}

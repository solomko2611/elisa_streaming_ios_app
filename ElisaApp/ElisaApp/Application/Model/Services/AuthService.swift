//
//  AuthService.swift
//  ElisaApp
//
//  Created by Dmitriy.K on 02.03.2022.
//

import Foundation

protocol AuthService {
    func login(login: String, password: String, completion: @escaping (Response<LoginResponse>) -> Void)
}

final class AuthServiceImpl {
    
    // MARK: - Private Properties
    
    private let networkManager: NetworkManager
    private let userDefaultsManager: UserDefaultsManager
    
    // MARK: - Initializer
    
    init(networkManager: NetworkManager, userDefaultsManager: UserDefaultsManager) {
        self.networkManager = networkManager
        self.userDefaultsManager = userDefaultsManager
    }
}

extension AuthServiceImpl: AuthService {
    
    func login(login: String, password: String, completion: @escaping (Response<LoginResponse>) -> Void) {
        let request = NetworkRequest(
            path: "login",
            method: .post,
            parameters: [
                "email": login,
                "password": password
            ],
            isAuthorizationRequired: false,
            host: .elisa
        )
        
        networkManager.execute(request: request) { [weak networkManager, weak userDefaultsManager] (response: Response<LoginResponse>) in
            switch response {
            case .success(let response):
                networkManager?.setAuthorizedStatus()
                networkManager?.setDynamicSignalURL(url: response.backendURL)
                userDefaultsManager?.set(response.backendURL, key: .backendURL)
            default: break
            }
            
            completion(response)
        }
    }
}

//
//  CollectionService.swift
//  ElisaApp
//
//  Created by Dmitriy.K on 10.03.2022.
//

import Foundation

protocol CollectionService {
    func getPages(completion: @escaping (Response<PageListResponse>) -> Void)
}

final class CollectionServiceImpl {
    
    // MARK: - Private Properties
    
    private let networkManager: NetworkManager
    private let userDefaultsManager: UserDefaultsManager
    
    // MARK: - Initializer
    
    init(networkManager: NetworkManager, userDefaultsManager: UserDefaultsManager) {
        self.networkManager = networkManager
        self.userDefaultsManager = userDefaultsManager
    }
}

extension CollectionServiceImpl: CollectionService {
    
    func getPages(completion: @escaping (Response<PageListResponse>) -> Void) {
        let request = NetworkRequest(
            path: "pages",
            method: .get,
            host: .elisa
        )
        
        networkManager.execute(request: request) { [weak networkManager, weak userDefaultsManager] (response: Response<PageListResponse>) in
            switch response {
            case .success(let response):
                networkManager?.setDynamicSignalURL(url: response.backendURL)
                userDefaultsManager?.set(response.backendURL, key: .backendURL)
            default: break
            }
            
            completion(response)
        }
    }
}


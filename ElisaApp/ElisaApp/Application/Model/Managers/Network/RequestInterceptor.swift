//
//  RequestInterceptor.swift
//  ElisaApp
//
//  Created by Dmitriy.K on 04.03.2022.
//

import Foundation
import Alamofire
import SwiftLazy

protocol RequestInterceptorDelegate: AnyObject {
    
}

protocol RequestInterceptor: Alamofire.RequestInterceptor {
    func setDelegate(delegate: RequestInterceptorDelegate)
    func isAuthorized() -> Bool
    func isTokenExpired() -> Bool
    func setAuthorizedStatus()
}

final class RequestInterceptorImpl {
    
    // MARK: - Private Properties
    
    private enum AuthorizationStatus {
        case unauthorized
        case authorized
        case inProgress
    }
    
    private let storage: UserProperties
    private let authProvider: Lazy<AuthProvider>
    private var authorizationStatus: AuthorizationStatus = .unauthorized
    
    private weak var delegate: RequestInterceptorDelegate?
    
    private var cache: [(RetryResult) -> Void] = []
    
    private let group = DispatchGroup()
    
    // MARK: - Initializer
    
    init(storage: UserProperties, authProvider: Lazy<AuthProvider>) {
        self.storage = storage
        self.authProvider = authProvider
        
        configureStatus()
    }
    
    // MARK: - RequestInterceptor
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var urlRequest = urlRequest
        
        if let accessToken = storage.token {
            urlRequest.headers.add(.authorization(bearerToken: accessToken))
        }
        
        completion(.success(urlRequest))
    }
    
    // MARK: - Private Methods
    
    private func configureStatus() {
        authorizationStatus = isTokenExpired() ? .unauthorized : .authorized
    }
}

extension RequestInterceptorImpl: RequestInterceptor {
    
    func setDelegate(delegate: RequestInterceptorDelegate) {
        self.delegate = delegate
    }
    
    func isAuthorized() -> Bool {
        authorizationStatus == .authorized
    }
    
    func isTokenExpired() -> Bool {
        return true
    }
    
    func setAuthorizedStatus() {
        self.authorizationStatus = .authorized
    }
}

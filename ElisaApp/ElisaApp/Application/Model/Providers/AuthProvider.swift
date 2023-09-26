//
//  AuthProvider.swift
//  ElisaApp
//
//  Created by Dmitriy.K on 04.03.2022.
//

import Foundation
import RxSwift
import RxRelay
import SwiftLazy


protocol AuthProvider {
    var state: BehaviorRelay<AuthProviderState> { get }
 
    func login(with login: String, and password: String)
    func clearErrorFields(type: LoginEvent.LoginTextFieldType, text: String?)
    func logout()
    func removeTokens(reason: UserPropertiesImpl.LogoutReason)
}

struct AuthProviderState: UpdatableStruct {
    var loginError: String?
    var passwordError: String?
    var loginSuccess: LoginResponse?
    var loginFailed: String?
}

final class AuthProviderImpl {
    
    // MARK: - Public Properties
    
    let state: BehaviorRelay<AuthProviderState>
    
    // MARK: - Private Properties
    
    private let authService: Lazy<AuthService>
    private let keychainManager: KeychainManager
    private let userProperties: UserProperties
  
    private let disposeBag = DisposeBag()
    
    // MARK: - Initializer
    
    init(authService: Lazy<AuthService>, userProperties: UserProperties, keychainManager: KeychainManager) {
        self.authService = authService
        self.keychainManager = keychainManager
        self.userProperties = userProperties
        self.state = BehaviorRelay<AuthProviderState>(value: AuthProviderState())
    }
    
    private func saveTokens(response: LoginResponse) {
        let response = response
        guard let data = try? JSONEncoder().encode(response) else { return }
        keychainManager.set(object: data, key: .authTokens)
        userProperties.update(with: response)
    }
    
    private func isEmailValid(with email: String) -> Bool {
        let regex = #"^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$"#
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: email)
    }
}

extension AuthProviderImpl: AuthProvider {
    func login(with login: String, and password: String) {
        let isEmailValid = self.isEmailValid(with: login)
        
        state.update(\.loginError, to: login.isEmpty ? "Please, enter your email" : !isEmailValid ? "Invalid email format" : nil)
        state.update(\.passwordError, to: password.isEmpty ? "Please, enter your password" : nil)
        state.update(\.loginFailed, to: nil)
        
        if !login.isEmpty && !password.isEmpty && isEmailValid {
            authService.value.login(login: login, password: password) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let data):
                    self.saveTokens(response: data)
                    self.state.update(\.loginSuccess, to: data)
                    self.state.update(\.loginSuccess, to: nil)
                case .failure(let error):
                    self.state.update(\.loginFailed, to: "Your email or password was incorrect.\nPlease try again")
                }
            }
        }
    }
    
    func clearErrorFields(type: LoginEvent.LoginTextFieldType, text: String?) {
        switch type {
        case .login:
            if let text = text {
                state.update(\.loginError, to: text.isEmpty ? "Please, enter your email" : !isEmailValid(with: text) ? "Invalid email format" : nil)
            } else {
                state.update(\.loginError, to: nil)
            }
        case .password:
            if let text = text {
                state.update(\.passwordError, to: text.isEmpty ? "Please, enter your password" : nil)
            } else {
                state.update(\.passwordError, to: nil)
            }
        }
        state.update(\.loginFailed, to: nil)
    }
    
    func logout() {
        removeTokens(reason: .manual)
    }
    
    func removeTokens(reason: UserPropertiesImpl.LogoutReason) {
        userProperties.clear(with: reason)
        keychainManager.remove(key: .authTokens)
        keychainManager.remove(key: .pushToken)
    }
}

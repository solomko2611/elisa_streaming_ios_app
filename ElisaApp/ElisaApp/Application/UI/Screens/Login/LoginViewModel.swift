//
//  LoginViewModel.swift
//  ElisaApp
//
//  Created by Dmitriy.K on 02.03.2022.
//

import Foundation
import RxSwift
import RxRelay

protocol LoginViewModel: AnyObject {
    var input: Observable<LoginInput> { get }
    var events: PublishSubject<LoginEvent> { get }

    var actionHandler: ((LoginViewModelActions) -> Void)? { get set }
}

class LoginViewModelImpl: LoginViewModel  {
    
    // MARK: - Public Properties
    
    let input: Observable<LoginInput>
    let events = PublishSubject<LoginEvent>()
    
    var actionHandler: ((LoginViewModelActions) -> Void)?
    
    // MARK: - Private Properties
    
    private let authProvider: AuthProvider
    private let disposeBag = DisposeBag()
    
    // MARK: - Initializer
    
    init(authProvider: AuthProvider) {
        self.authProvider = authProvider
        
        input = authProvider.state.map({
            LoginInput(emailError: $0.loginError,
                       passwordError: $0.passwordError,
                       loginSuccess: $0.loginSuccess,
                       loginFailed: $0.loginFailed)
        })
        
        events.subscribe(onNext: { [weak self] event in
            self?.processEvent(event: event)
        }).disposed(by: disposeBag)
        
        authProvider.state
            .map({$0.loginSuccess})
            .subscribe(onNext: { [weak self] loginSuccess in
                if loginSuccess != nil {
                    self?.actionHandler?(.loginSuccess)
                }
            }).disposed(by: disposeBag)
    }
    
    // MARK: - Private Methods
    
    private func processEvent(event: LoginEvent) {
        switch event {
        case .loginPressed(let login, let password):
            authProvider.login(with: login.trimmingCharacters(in: .whitespacesAndNewlines), and: password.trimmingCharacters(in: .whitespacesAndNewlines))
        case .forgotPressed:
            self.actionHandler?(.forgotPassword)
        case .textFieldChanged(let type, let text):
            self.authProvider.clearErrorFields(type: type, text: text)
        }
    }
}

//
//  AuthCoordinator.swift
//  ElisaApp
//
//  Created by Dmitriy.K on 02.03.2022.
//

import UIKit
import DITranquillity
import RxSwift
import SafariServices


final class AuthCoordinator: BaseCoordinator, ErrorProcessing {

    var onAuthenticated: (() -> Void)?
    
    // MARK: Private Properties
    
    private let container: DIContainer
    private let disposeBag = DisposeBag()
    
    // MARK: Public Properties
    
    let router: Router
    
    // MARK: Initializer
    
    init(router: Router, container: DIContainer) {
        self.router = router
        self.container = container
    }
    
    override func start() {
        showLogin()
    }
    
    // MARK: - Private Methods
    
    private func showLogin() {
        let loginDependency: LoginDependency = container.resolve()
        loginDependency.viewModel.actionHandler = { [weak self] action in
            switch action {
            case .loginSuccess:
                self?.onAuthenticated?()
            case .forgotPassword:
                self?.showResetPassword()
            }
        }
        router.setRootModule(loginDependency.viewController)
    }
    
    private func showResetPassword() {
        if let url = URL(string: "https://app.elisa.io/auth/reset") {
            let resetPasswordVC = SFSafariViewController(url: url)
            router.present(resetPasswordVC, animated: true)
        }
    }
}

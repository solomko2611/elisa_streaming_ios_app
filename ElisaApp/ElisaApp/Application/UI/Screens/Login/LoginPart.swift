//
//  LoginPart.swift
//  ElisaApp
//
//  Created by Dmitriy.K on 02.03.2022.
//

import DITranquillity

final class LoginPart: DIPart {
    static func load(container: DIContainer) {
        
        container.register(LoginViewModelImpl.init)
            .as(LoginViewModel.self)
            .lifetime(.objectGraph)
        container.register(LoginViewController.init(viewModel:))
            .lifetime(.objectGraph)
        container.register(LoginDependency.init(viewModel:viewController:))
            .lifetime(.prototype)
    }
}

struct LoginDependency {
    let viewModel: LoginViewModel
    let viewController: LoginViewController
}

//
//  AppCoordinator.swift
//  ElisaApp
//
//  Created by Dmitriy.K on 02.03.2022.
//

import UIKit
import DITranquillity

final class AppCoordinator: BaseCoordinator {

    // MARK: - Private Properties

    private let window: UIWindow
    private let container: DIContainer

    // MARK: - Initializer

    init(window: UIWindow, container: DIContainer) {
        self.window = window
        self.container = container
    }
    
    override func start() {
        checkLogin()
    }
    
    override func start(with option: DeepLinkOption? = nil) {
        start()
    }
    
    private func checkLogin() {
        let userProperties: UserProperties = container.resolve()
        if userProperties.isLoggedIn() {
            showStreamList()
        } else {
            showLogin()
        }
    }

    // MARK: - Private Methods

    private func showLogin() {
        let navigationController = BaseNavigationController()
        let router = RouterImpl(rootController: navigationController)
        
        let authCoordinator = AuthCoordinator(router: router, container: container)
        authCoordinator.onAuthenticated = { [weak self] in
            DispatchQueue.main.async {
                self?.showStreamList()
            }
        }
        authCoordinator.start()
        addDependency(authCoordinator)
        window.rootViewController = navigationController
    }
    
    
    private func showStreamList() {
        let navigationController = BaseNavigationController()
        let router = RouterImpl(rootController: navigationController)
        
        let streamCoordinator = PageCoordinator(router: router, container: container)
        streamCoordinator.onClose = {
            DispatchQueue.main.async { [weak self] in
                self?.showLogin()
            }
        }
        streamCoordinator.start()
        addDependency(streamCoordinator)
        window.rootViewController = navigationController
    }
}


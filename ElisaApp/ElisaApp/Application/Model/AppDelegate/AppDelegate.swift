//
//  AppDelegate.swift
//  ElisaApp
//
//  Created by Dmitriy.K on 02.03.2022.
//

import UIKit
import DITranquillity
import IQKeyboardManagerSwift
import AVFoundation
import Firebase

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var applicationWillTerminate: (() -> Void)?
    
    private let container = DIContainer()

    var window: UIWindow?
    private var applicationCoordinator: AppCoordinator?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
        configureAppearance()
        configureFramework()
        registerParts()
        
        let window = UIWindow()
        let applicationCoordinator = AppCoordinator(window: window, container: container)
        self.applicationCoordinator = applicationCoordinator
        self.window = window

        window.makeKeyAndVisible()
        applicationCoordinator.start()
        FirebaseApp.configure()

        return true
    }
    
//    func applicationWillTerminate(_ application: UIApplication) {
//        applicationWillTerminate?()
//    }
        
    private func configureFramework() {
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
    }

    // MARK: - Private functions

    private func registerParts() {
        container.append(part: BasePart.self)
        container.append(part: NetworkPart.self)
        container.append(part: ServicesPart.self)
        container.append(part: ProvidersPart.self)        
        container.append(part: LoginPart.self)
        container.append(part: PageListPart.self)
        container.append(part: StreamsPart.self)
    }
    
    private func configureAppearance() {
        
    }
}


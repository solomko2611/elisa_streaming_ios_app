//
//  TabBarRouterImpl.swift
//  ForaArchitecture
//
//  Created by Dmitriy.K on 09.02.2022.
//

import UIKit

final class TabBarRouterImpl: TabBarRouter {
    
    private weak var tabBarController: UITabBarController?
    
    init(tabBarController: UITabBarController) {
        self.tabBarController = tabBarController
    }
    
    func setViewControllers(viewControllers: [UIViewController], animated: Bool) {
        tabBarController?.setViewControllers(viewControllers, animated: animated)
    }
    
    func toPresent() -> UIViewController? {
        return tabBarController
    }
    
    func present(_ module: Presentable?) {
        present(module, animated: true)
    }
    
    func present(_ module: Presentable?, animated: Bool) {
        guard let controller = module?.toPresent() else { return }
        if let presented = tabBarController?.topPresentedViewController {
            if presented is UIAlertController && controller is UIAlertController {
                return
            }
            presented.present(controller, animated: true, completion: nil)
        } else {
            tabBarController?.present(controller, animated: animated, completion: nil)
        }
    }
    
    func dismissModule() {
        dismissModule(animated: true, completion: nil)
    }
    
    func dismissModule(animated: Bool, completion: (() -> Void)?) {
        if let presented = tabBarController?.topPresentedViewController {
            presented.dismiss(animated: animated, completion: completion)
        } else {
            tabBarController?.dismiss(animated: animated, completion: completion)
        }
    }
}

//
//  TabBarRouter.swift
//  ForaArchitecture
//
//  Created by Dmitriy.K on 09.02.2022.
//

import UIKit

protocol TabBarRouter: Presentable {
    func setViewControllers(viewControllers: [UIViewController], animated: Bool)
    
    func present(_ module: Presentable?)
    func present(_ module: Presentable?, animated: Bool)

    func dismissModule()
    func dismissModule(animated: Bool, completion: (() -> Void)?)
}

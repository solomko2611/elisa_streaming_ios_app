//
//  BaseNavigationController.swift
//  Nucleus
//
//  Created by Mikhail Sein on 07.06.2021.
//

import UIKit

final class BaseNavigationController: UINavigationController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        topViewController?.preferredStatusBarStyle ?? .darkContent
    }
    
    override var shouldAutorotate: Bool {
        topViewController?.shouldAutorotate ?? false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .portrait
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.prefersLargeTitles = true
    }
}

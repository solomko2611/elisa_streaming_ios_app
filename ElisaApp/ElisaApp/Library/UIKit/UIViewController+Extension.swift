//
//  UIViewController+Extension.swift
//  ForaArchitecture
//
//  Created by Mikhail Sein on 16.12.2021.
//

import UIKit

extension UIViewController {
    
    /// Returns top presented controller
    var topPresentedViewController: UIViewController? {
        guard var topPresentedController = presentedViewController else { return nil }
        
        while let presentedController = topPresentedController.presentedViewController {
            topPresentedController = presentedController
        }
        
        return topPresentedController
    }
}

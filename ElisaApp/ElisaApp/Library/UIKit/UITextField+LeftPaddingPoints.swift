//
//  UITextField+LeftPaddingPoints.swift
//  ForaArchitecture
//
//  Created by Georgii Kazhuro on 08.04.2021.
//

import UIKit

extension UITextField {
    func setLeftPaddingPoints(_ amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
}

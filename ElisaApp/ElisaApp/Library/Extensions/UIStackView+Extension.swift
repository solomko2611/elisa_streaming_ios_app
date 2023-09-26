//
//  UIStackView+Extension.swift
//  Nucleus
//
//  Created by Mikhail Sein on 01.09.2021.
//

import UIKit

extension UIStackView {
    /// Adds a views to the end of the arrangedSubviews array.
    /// - Parameter views: Zero or more views to add.
    func addArrangedSubviews(_ views: UIView...) {
        views.forEach {
            addArrangedSubview($0)
        }
    }
}

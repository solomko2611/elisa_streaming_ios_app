//
//  UIFont+Extension.swift
//  ElisaApp
//
//  Created by Dmitry Karpinsky on 09.03.2022.
//

import UIKit

extension UIFont {
    
    enum Font: String {
        case regular = "Poppins-Regular"
        case semibold = "Poppins-SemiBold"
        case bold = "Poppins-Bold"
        case light = "Poppins-Light"
    }

    static func poppinsFont(ofSize fontSize: CGFloat, font: Font) -> UIFont {
        return self.init(name: font.rawValue, size: fontSize)!
    }
}

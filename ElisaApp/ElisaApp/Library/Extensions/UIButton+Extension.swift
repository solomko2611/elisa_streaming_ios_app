//
//  UIButton+Extension.swift
//  ElisaApp
//
//  Created by Dmitriy.K on 03.03.2022.
//

import UIKit
 
extension UIButton {
    /// Configure button with given attributes
    /// - Parameters:
    ///   - title: The title of the view (optional)
    ///   - titleColor: The color of the text (optional)
    ///   - font: The font of the text (system 17 default)
    ///   - tintColor: The tint color to apply to the button title and image
    ///   - image: The image of the view (optional)
    ///   - backgroundColor: The view’s background color (optional)
    ///   - cornerRadius: The radius to use when drawing rounded corners for the layer’s background. Animatable. (zero default)
    ///   - cornerCurve: Defines the curve used for rendering the rounded corners of the layer. (.continuous default)
    func configure(
        title: String? = nil,
        titleColor: UIColor? = nil,
        font: UIFont? = .systemFont(ofSize: 17),
        tintColor: UIColor? = nil,
        image: UIImage? = nil,
        backgroundColor: UIColor? = nil,
        cornerRadius: CGFloat = 0,
        cornerCurve: CALayerCornerCurve = .continuous
    ) {
        self.setTitle(title, for: .normal)
        self.setTitleColor(titleColor, for: .normal)
        self.setTitleColor(titleColor?.withAlphaComponent(0.7), for: .highlighted)
        self.titleLabel?.font = font
        if let tintColor = tintColor {
            self.tintColor = tintColor
        }
        self.setImage(image, for: .normal)
        self.backgroundColor = backgroundColor
        self.layer.cornerRadius = cornerRadius
        self.layer.cornerCurve = cornerCurve
    }
}

//
//  UILabel+Extension.swift
//  ElisaApp
//
//  Created by Dmitriy.K on 11.03.2022.
//

import UIKit

extension UILabel {
    
    /// Configure label with given attributes
    /// - Parameters:
    ///   - text: The text that the label displays (optional)
    ///   - textColor: The color of the text (optional)
    ///   - backgroundColor: The view’s background color (optional)
    ///   - font: The font of the text (system 17 default)
    ///   - textAligment: The technique for aligning the text (natural default)
    ///   - numberOfLines: The maximum number of lines for rendering text (default 1)
    ///   - cornerRadius: The radius to use when drawing rounded corners for the layer’s background. Animatable. (default zero)
    ///   - clipsToBounds: A Boolean value that determines whether subviews are confined to the bounds of the view. (default false)
    ///   - minimumScaleFactor: The minimum scale factor for the label’s text
    func configure(
        text: String? = nil,
        textColor: UIColor? = nil,
        backgroundColor: UIColor? = .clear,
        font: UIFont? = .systemFont(ofSize: 17),
        textAligment: NSTextAlignment = .natural,
        numberOfLines: Int = 1,
        cornerRadius: CGFloat = .zero,
        clipsToBounds: Bool = false,
        minimumScaleFactor: CGFloat = .zero
    ) {
        self.text = text
        self.textColor = textColor
        self.backgroundColor = backgroundColor
        self.font = font
        self.textAlignment = textAligment
        self.numberOfLines = numberOfLines
        self.layer.cornerRadius = cornerRadius
        self.clipsToBounds = clipsToBounds
        self.layer.cornerCurve = .continuous
        self.adjustsFontSizeToFitWidth = minimumScaleFactor != .zero
        self.minimumScaleFactor = minimumScaleFactor
    }
}

//
//  UITextField+Extension.swift
//  ElisaApp
//
//  Created by Dmitriy.K on 03.03.2022.
//

import UIKit

extension UITextField {
    
    /// Configure textfield with given attributes
    /// - Parameters:
    ///   - placeholder: The string that displays when there is no other text in the text field (empty default)
    ///   - placeholderColor: The color of the text (.gray3 default)
    ///   - text: The text that the text field displays (empty default)
    ///   - textColor: The color of the text (.gray1 default)
    ///   - font: The font of the text (system 17 default)
    ///   - backgroundColor: The view’s background color (optional)
    ///   - cornerRadius: The radius to use when drawing rounded corners for the layer’s background. Animatable. (zero default)
    ///   - cornerCurve: Defines the curve used for rendering the rounded corners of the layer. (.continuous default)
    ///   - borderWidth: The width of the layer’s border. Animatable. (zero default)
    ///   - borderColor: The color of the layer’s border. Animatable. (optional)
    ///   - tintColor: The first nondefault tint color value in the view’s hierarchy, ascending from and starting with the view itself. (.blue default)
    ///   - textContentType: The semantic meaning for a text input area. (optional)
    ///   - isSecure: A Boolean value that indicates whether the text object disables text copying and, in some cases, hides the text that the user enters. (false default)
    ///   - autoCapitalizationType: The autocapitalization style for the text object (.none default)
    ///   - autocorrectionType: The autocorrection style for the text object (.no default)
    ///   - keyboardType: The keyboard type for the text object (default value is .default)
    func configure(
        placeholder: String = "",
        placeholderColor: UIColor = .gray1,
        text: String = "",
        textColor: UIColor = .black,
        font: UIFont? = .systemFont(ofSize: 17),
        backgroundColor: UIColor? = nil,
        cornerRadius: CGFloat = 0,
        cornerCurve: CALayerCornerCurve = .continuous,
        borderWidth: CGFloat = 0,
        borderColor: UIColor? = nil,
        tintColor: UIColor = .blue,
        textContentType: UITextContentType? = nil,
        isSecure: Bool = false,
        autoCapitalizationType: UITextAutocapitalizationType = .none,
        autoCorrectionType: UITextAutocorrectionType = .no,
        keyboardType: UIKeyboardType = .default
    ) {
        self.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [.foregroundColor: placeholderColor])
        self.text = text
        self.textColor = textColor
        self.font = font
        self.backgroundColor = backgroundColor
        self.layer.cornerRadius = cornerRadius
        self.layer.cornerCurve = cornerCurve
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor?.cgColor
        self.tintColor = tintColor
        self.textContentType = textContentType
        self.isSecureTextEntry = isSecure
        self.autocapitalizationType = autoCapitalizationType
        self.autocorrectionType = .no
        self.keyboardType = keyboardType
    }
}

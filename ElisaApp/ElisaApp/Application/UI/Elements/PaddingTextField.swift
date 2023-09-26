//
//  PaddingTextField.swift
//  ElisaApp
//
//  Created by Dmitriy.K on 03.03.2022.
//

import UIKit

class PaddingTextField: UITextField {
    
    // MARK: - Private Properties
    
    private(set) var padding: UIEdgeInsets
    
    // MARK: - Initializer
    
    init(padding: UIEdgeInsets = .zero) {
        self.padding = padding
        
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Overriding
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: padding)
    }
    
    // MARK: - Public Methods
    
    func setPadding(_ padding: UIEdgeInsets) {
        self.padding = padding
    }
}

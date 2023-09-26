//
//  UIView+Extension.swift
//  ElisaApp
//
//  Created by Dmitriy.K on 03.03.2022.
//

import UIKit

extension UIView {
    
    /// Activate constraints with zero padding
    /// - Parameters:
    ///   - top: top anchor
    ///   - leading: leading anchor
    ///   - trailing: trailing anchor
    ///   - bottom: bottom anchor
    func addConstraints(to view: UIView) {
        addConstraints(
            top: view.topAnchor,
            leading: view.leadingAnchor,
            trailing: view.trailingAnchor,
            bottom: view.bottomAnchor
        )
    }
    
    /// Activate constraints with zero padding
    /// - Parameters:
    ///   - top: top anchor
    ///   - leading: leading anchor
    ///   - trailing: trailing anchor
    ///   - bottom: bottom anchor
    func addConstraints(
        top: NSLayoutYAxisAnchor,
        leading: NSLayoutXAxisAnchor,
        trailing: NSLayoutXAxisAnchor,
        bottom: NSLayoutYAxisAnchor
    ) {
        addConstraints(
            top: top,
            leading: leading,
            trailing: trailing,
            bottom: bottom,
            topPadding: 0,
            leadingPadding: 0,
            trailingPadding: 0,
            bottomPadding: 0
        )
    }
    
    /// Activate constraints with given attributes
    /// - Parameters:
    ///   - top: top anchor (optional)
    ///   - leading: leading anchor (optional)
    ///   - trailing: trailing anchor (optional)
    ///   - bottom: bottom anchor (optional)
    ///   - topPadding: top padding (zero default)
    ///   - leadingPadding: leading padding (zero default)
    ///   - trailingPadding: trailing padding (zero default)
    ///   - bottomPadding: bottom padding (zero default)
    ///   - width: width size (optional)
    ///   - widthAnchor: width anchor (optional)
    ///   - widthAnchorMultiplier: width anchor multiplier (1.0 default)
    ///   - heigth: height size (optional)
    ///   - heightAnchor: height anchor (optional)
    ///   - heightAnchorMultiplier: height anchor multiplier (1.0 default)
    ///   - centerX: view (optional)
    ///   - centerXPadding: center X padding (zero default)
    ///   - centerXMultiplier: center X multiplier (1.0 default)
    ///   - centerY: view (optional)
    ///   - centerYPadding: center Y padding (zero default)
    ///   - centerYMultiplier: center Y multiplier (1.0 default)
    func addConstraints(
        top: NSLayoutYAxisAnchor? = nil,
        leading: NSLayoutXAxisAnchor? = nil,
        trailing: NSLayoutXAxisAnchor? = nil,
        bottom: NSLayoutYAxisAnchor? = nil,
        topPadding: CGFloat = .zero,
        leadingPadding: CGFloat = .zero,
        trailingPadding: CGFloat = .zero,
        bottomPadding: CGFloat = .zero,
        width: CGFloat? = nil,
        widthAnchor: NSLayoutDimension? = nil,
        widthAnchorMultiplier: CGFloat = CGFloat(1.0),
        height: CGFloat? = nil,
        heightAnchor: NSLayoutDimension? = nil,
        heightAnchorMultiplier: CGFloat = CGFloat(1.0),
        centerX: UIView? = nil,
        centerXPadding: CGFloat = .zero,
        centerXMultiplier: CGFloat = CGFloat(1.0),
        centerY: UIView? = nil,
        centerYPadding: CGFloat = .zero,
        centerYMultiplier: CGFloat = CGFloat(1.0)
    ) {
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            topAnchor.constraint(equalTo: top, constant: topPadding).isActive = true
        }
        
        if let leading = leading {
            leadingAnchor.constraint(equalTo: leading, constant: leadingPadding).isActive = true
        }
        
        if let trailing = trailing {
            trailingAnchor.constraint(equalTo: trailing, constant: -trailingPadding).isActive = true
        }
        
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -bottomPadding).isActive = true
        }
        
        if let width = width {
            self.widthAnchor.constraint(equalToConstant: width).isActive = true
        } else if let widthAnchor = widthAnchor {
            self.widthAnchor.constraint(equalTo: widthAnchor, multiplier: widthAnchorMultiplier).isActive = true
        }
        
        if let height = height {
            self.heightAnchor.constraint(equalToConstant: height).isActive = true
        } else if let heightAnchor = heightAnchor {
            self.heightAnchor.constraint(equalTo: heightAnchor, multiplier: heightAnchorMultiplier).isActive = true
        }
        
        if let centerX = centerX {
            NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: centerX, attribute: .centerX, multiplier: centerXMultiplier, constant: centerXPadding).isActive = true
        }
        
        if let centerY = centerY {
            NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: centerY, attribute: .centerY, multiplier: centerYMultiplier, constant: centerYPadding).isActive = true
        }
    }
    
    /// Adds a views to the end of the receiver’s list of subviews.
    /// - Parameter views: Zero or more views to add.
    func addSubviews(_ views: UIView...) {
        views.forEach {
            addSubview($0)
        }
    }
}

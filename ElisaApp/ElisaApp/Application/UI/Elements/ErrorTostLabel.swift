//
//  ErrorTostLabel.swift
//  ElisaApp
//
//  Created by alexandr galkin on 13.07.2022.
//

import Foundation
import UIKit

final class ErrorTostLabel: UIView {
    private lazy var label: PaddingLabel = {
        let label = PaddingLabel()
        label.textEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        label.textColor = .white
        label.backgroundColor = UIColor.blurredGray
        label.layer.masksToBounds = true
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var blurEffectView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .systemChromeMaterialDark)
        let view = UIVisualEffectView(effect: effect)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubviews(blurEffectView, label)
        
        label.addConstraints(top: topAnchor, leading: leadingAnchor, trailing: trailingAnchor, bottom: bottomAnchor)
        blurEffectView.addConstraints(top: topAnchor, leading: leadingAnchor, trailing: trailingAnchor, bottom: bottomAnchor)
    }
    
    public func configure(text: String) {
        label.text = text
    }
}

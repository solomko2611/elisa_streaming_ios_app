//
//  SwitchCameraButton.swift
//  ElisaApp
//
//  Created by alexandr galkin on 13.10.2022.
//

import UIKit

final class BlurredButton: UIControl {
    
    public var imageViewIndent: CGFloat = 0.0 {
        didSet {
            imageView.removeFromSuperview()
            addSubview(imageView)
            imageView.addConstraints(top: topAnchor,
                                     leading: leadingAnchor,
                                     trailing: trailingAnchor,
                                     bottom: bottomAnchor,
                                     topPadding: imageViewIndent,
                                     leadingPadding: imageViewIndent,
                                     trailingPadding: imageViewIndent,
                                     bottomPadding: imageViewIndent)
        }
    }
    
    private lazy var blurEffectView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .systemChromeMaterialDark)
        let view = UIVisualEffectView(effect: effect)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var opacityView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.blurredGray
        return view
    }()
    
    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setImage(image: UIImage?) {
        imageView.image = image
    }
    
    private func setupView() {
        addSubviews(blurEffectView, opacityView, imageView)
        clipsToBounds = true
        imageView.isUserInteractionEnabled = false
        blurEffectView.isUserInteractionEnabled = false
        opacityView.isUserInteractionEnabled = false
        
        opacityView.addConstraints(top: topAnchor, leading: leadingAnchor, trailing: trailingAnchor, bottom: bottomAnchor)
        imageView.addConstraints(top: topAnchor, leading: leadingAnchor, trailing: trailingAnchor, bottom: bottomAnchor,
                                 topPadding: imageViewIndent, leadingPadding: imageViewIndent, trailingPadding: imageViewIndent, bottomPadding: imageViewIndent)
        blurEffectView.addConstraints(top: topAnchor, leading: leadingAnchor, trailing: trailingAnchor, bottom: bottomAnchor)
    }
}

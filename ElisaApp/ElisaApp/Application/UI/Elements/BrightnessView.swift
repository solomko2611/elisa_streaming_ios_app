//
//  BrightnessView.swift
//  ElisaApp
//
//  Created by Mikhail Sein on 30.03.2022.
//

import UIKit

final class BrightnessView: UIView {
    
    // MARK: - Public Properties
    
    var onValueChanged: ((Double) -> Void)?
    
    // MARK: - Private Properties
    
    private lazy var valueLayer: CALayer = {
        let layer = CALayer()
        layer.backgroundColor = CGColor(red: 1, green: 1, blue: 1, alpha: 1)
        return layer
    }()
    
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
    
    private var value: Double = 0.0 {
        didSet {
            let yPosition = (1.0 - value) * bounds.height
            valueLayer.frame = CGRect(x: 0, y: yPosition, width: bounds.width, height: bounds.height - yPosition)
            onValueChanged?(value)
        }
    }
    
    private lazy var brightnessImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "brightness"))
        return imageView
    }()
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureView()
    }
    
    // MARK: - Overriding
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = bounds.width / 2
        
        let brightnessImageViewSize = CGSize(width: 28, height: 28)
        brightnessImageView.frame = CGRect(origin: CGPoint(x: bounds.width / 2 - brightnessImageViewSize.width / 2, y: bounds.height - 10 - brightnessImageViewSize.height), size: brightnessImageViewSize)
        
        let valueLayerPosition = (1.0 - value) * bounds.height
        valueLayer.frame = CGRect(x: 0, y: valueLayerPosition, width: bounds.width, height: bounds.height - valueLayerPosition)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else { return }
        value = max(0, min(1 - location.y / bounds.height, 1))
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else { return }
        value = max(0, min(1 - location.y / bounds.height, 1))
    }
    
    // MARK: - Private Methods
    
    private func configureView() {
        opacityView.layer.insertSublayer(valueLayer, at: 0)
        clipsToBounds = true
        backgroundColor = .clear
        addSubviews(blurEffectView, opacityView, brightnessImageView)
        opacityView.addConstraints(top: topAnchor, leading: leadingAnchor, trailing: trailingAnchor, bottom: bottomAnchor)
        blurEffectView.addConstraints(top: topAnchor, leading: leadingAnchor, trailing: trailingAnchor, bottom: bottomAnchor)
    }
    
    func setValue(_ newValue: Double) {
        value = max(0, min(newValue, 1))
    }
}

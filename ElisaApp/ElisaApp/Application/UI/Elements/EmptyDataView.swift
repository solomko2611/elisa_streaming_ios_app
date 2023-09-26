//
//  EmptyDataView.swift
//  Nucleus
//
//  Created by Mikhail Sein on 14.05.2021.
//

import UIKit

final class EmptyDataView: UIView {
    
    struct State {
        enum Image: String {
            case emptyCampaign = "empty_campaign"
        }
        
        let title: String
        let subtitle: String?
        let image: Image
        
        init(title: String, subtitle: String? = nil, image: Image = .emptyCampaign) {
            self.title = title
            self.subtitle = subtitle
            self.image = image
        }
    }
    
    // MARK: - Private Properties
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.configure(textColor: .black, font: .poppinsFont(ofSize: 20, font: .bold))
        label.textAlignment = .center
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.configure(textColor: .black, font: .poppinsFont(ofSize: 17, font: .regular))
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    // MARK: - Initializer
    
    init() {
        super.init(frame: .zero)
        
        configureView()
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Methods
    
    private func configureView() {
        addSubviews(imageView, titleLabel, subtitleLabel)
    }
    
    private func configureConstraints() {
        imageView.addConstraints(top: topAnchor, leading: leadingAnchor, trailing: trailingAnchor)
        titleLabel.addConstraints(top: imageView.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, topPadding: 32)
        subtitleLabel.addConstraints(top: titleLabel.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, bottom: bottomAnchor, topPadding: 8)
    }
    
    // MARK: - Public Methods
    
    func configureView(with state: State) {
        titleLabel.text = state.title
        subtitleLabel.text = state.subtitle
        imageView.image = UIImage(named: state.image.rawValue)
    }
}

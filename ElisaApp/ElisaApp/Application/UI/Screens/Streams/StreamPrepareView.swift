//
//  StreamPrepareView.swift
//  ElisaApp
//
//  Created by alexandr galkin on 24.11.2022.
//

import UIKit

final class StreamPrepareView: UIView {
    private lazy var loaderIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .large)
        view.color = .white
        return view
    }()
    
    private lazy var prepareLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.poppinsFont(ofSize: 17, font: .bold)
        label.text = "Preparing"
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.poppinsFont(ofSize: 17, font: .light)
        label.textColor = .white.withAlphaComponent(0.5)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private lazy var labelStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [prepareLabel, descriptionLabel])
        stackView.axis = .vertical
        stackView.spacing = 16.0
        stackView.alignment = .center
        return stackView
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [loaderIndicator, labelStackView])
        stackView.axis = .vertical
        stackView.spacing = 25.0
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(descriptionText: String) {
        descriptionLabel.text = descriptionText
    }
    
    private func setupView() {
        loaderIndicator.startAnimating()
        backgroundColor = .black.withAlphaComponent(0.8)
        addSubviews(stackView)
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 10),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 48),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -48),
        ])
    }
}

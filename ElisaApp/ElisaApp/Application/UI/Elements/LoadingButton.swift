//
//  LoadingButton.swift
//  ElisaApp
//
//  Created by alexandr galkin on 23.05.2022.
//

import UIKit

final class LoadingButton: UIButton {
    let activityIndicator = UIActivityIndicatorView(style: .medium)
    
    var isLoading: Bool = false {
        didSet {
            if isLoading {
                showActivityIndicator()
            } else {
                hideActivityIndicator()
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupActivityView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupActivityView() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
    
    private func showActivityIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.color = .accentGreen2
        activityIndicator.startAnimating()
        isUserInteractionEnabled = false
        setTitle("", for: .normal)
    }
    
    private func hideActivityIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
        isUserInteractionEnabled = true
    }
}

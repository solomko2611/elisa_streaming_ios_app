//
//  BaseViewController.swift
//  ElisaApp
//
//  Created by Dmitriy.K on 02.03.2022.
//

import UIKit

class BaseViewController: UIViewController {
    
    
    var isLoginFlow: Bool = true {
        didSet {
            if isLoginFlow {
                logoImageLeadingPadding = 32.0
            } else {
                logoImageLeadingPadding = 18.0
            }
        }
    }
    
    private(set) lazy var topLine: UIImageView = {
        let view = UIImageView(image: UIImage(named: "topLine"))
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private(set) lazy var logoImage: UIImageView = {
        let view = UIImageView(image: UIImage(named: "mainLogo"))
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var logoImageLeadingPadding: CGFloat = 32.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(topLine)
        view.addSubview(logoImage)
        topLine.addConstraints(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor, topPadding: 20.0, height: 8.0)
        logoImage.addConstraints(top: topLine.bottomAnchor, leading: view.leadingAnchor, topPadding: 16.0, leadingPadding: logoImageLeadingPadding)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .darkContent
    }
    
    override var shouldAutorotate: Bool {
        true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .portrait
    }
}

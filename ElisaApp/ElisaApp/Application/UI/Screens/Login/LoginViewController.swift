//
//  LoginViewController.swift
//  ElisaApp
//
//  Created by Dmitriy.K on 02.03.2022.
//

import UIKit
import RxSwift

class LoginViewController: BaseViewController {
    
    
    // MARK: - Private Properties
    
    private let viewModel: LoginViewModel
    private var disposeBag: DisposeBag?
    
    private lazy var languageButton: UIButton = {
        let button = UIButton()
        button.configure(title: "Eng",
                         titleColor: UIColor.black,
                         font: UIFont.poppinsFont(ofSize: 17, font: .regular),
                         backgroundColor: UIColor.white,
                         cornerRadius: 19)
        button.layer.borderWidth = 1.0
        button.layer.borderColor = UIColor.gray6.cgColor
        return button
    }()
    
    private let loginView = LoginView()

    // MARK: - Initializer
    
    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - ViewController Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureConstraints()
        configureObservables()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: - Private Methods

    private func configureView() {
        view.backgroundColor = .white
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func configureObservables() {
        let disposeBag = DisposeBag()
        viewModel.input.observe(on: MainScheduler.asyncInstance).subscribe(onNext: { [weak self] data in
            self?.render(data: data)
        }).disposed(by: disposeBag)
        
        loginView.events.subscribe(onNext: { [weak self] event in
            self?.viewModel.events.onNext(event)
        }).disposed(by: disposeBag)
        
        self.disposeBag = disposeBag
    }
    
    private func configureConstraints() {
        view.addSubviews(languageButton, loginView)
        
        languageButton.addConstraints(top: topLine.bottomAnchor,
                                      trailing: view.trailingAnchor,
                                      topPadding: 19.0,
                                      trailingPadding: 32.0,
                                      width: 64,
                                      height: 38)
        
        loginView.addConstraints(top: languageButton.bottomAnchor,
                                 leading: view.leadingAnchor,
                                 trailing: view.trailingAnchor,
                                 bottom: view.safeAreaLayoutGuide.bottomAnchor,
                                 topPadding: 10)
    }
    
    private func render(data: LoginInput) {
        loginView.configureView(with: data)
    }
}

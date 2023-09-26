//
//  LoginView.swift
//  ElisaApp
//
//  Created by Dmitriy.K on 02.03.2022.
//

import UIKit
import RxSwift
import RxCocoa

class LoginView: UIView {
    
    // MARK: - Public Properties
    
    let events = PublishSubject<LoginEvent>()
    
    // MARK: - Private Properties
    
    private var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.showsVerticalScrollIndicator = false
        return scroll
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var logoView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var welcomeLabel: UILabel = {
        let label = UILabel()
        label.configure(text: "WELCOME",
                        textColor: UIColor.accentGreen,
                        backgroundColor: UIColor.clear,
                        font: UIFont.poppinsFont(ofSize: 17, font: .bold))
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var loginLabel: UILabel = {
        let label = UILabel()
        label.configure(text: "Please login",
                        textColor: UIColor.black,
                        backgroundColor: UIColor.clear,
                        font: UIFont.poppinsFont(ofSize: 36, font: .semibold))
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var emailLabel: UILabel = {
        let label = UILabel()
        label.configure(text: "Email",
                        textColor: UIColor.black,
                        backgroundColor: UIColor.clear,
                        font: UIFont.poppinsFont(ofSize: 15, font: .semibold))
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var passwordLabel: UILabel = {
        let label = UILabel()
        label.configure(text: "Password",
                        textColor: UIColor.black,
                        backgroundColor: UIColor.clear,
                        font: UIFont.poppinsFont(ofSize: 15, font: .semibold))
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var emailTextField: PaddingTextField = {
        let textField = PaddingTextField(padding: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16))
        textField.configure(placeholder: "Email",
                            font: .poppinsFont(ofSize: 17, font: .light),
                            backgroundColor: UIColor.white,
                            cornerRadius: 26,
                            borderWidth: 1,
                            borderColor: UIColor.gray6,
                            textContentType: .emailAddress,
                            keyboardType: .emailAddress)
        textField.delegate = self
        #if DEV
        textField.text = "apple@elisa.io"
        #endif
        
        return textField
    }()
    
    private lazy var emailErrorStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        return stackView
    }()
    
    private lazy var emailErrorTextLabel: UILabel = {
        let label = UILabel()
        label.configure(textColor: .red, font: .poppinsFont(ofSize: 15, font: .light), textAligment: .left)
        return label
    }()
    
    private lazy var emailErrorImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "loginFieldError"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var passwordTextField: PaddingTextField = {
        let textField = PaddingTextField(padding: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 52))
        textField.configure(placeholder: "Password",
                            font: .poppinsFont(ofSize: 17, font: .light),
                            backgroundColor: UIColor.white,
                            cornerRadius: 26,
                            borderWidth: 1,
                            borderColor: UIColor.gray6,
                            textContentType: .password,
                            isSecure: true)
        textField.delegate = self
        #if DEV
        textField.text = "ELISA123!"
        #endif
        
        return textField
    }()
    
    private let eyeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "secureEye"), for: .normal)
        button.tintColor = .gray1
        return button
    }()
    
    private lazy var passwordErrorStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        return stackView
    }()
    
    private lazy var passwordErrorTextLabel: UILabel = {
        let label = UILabel()
        label.configure(textColor: .red, font: .poppinsFont(ofSize: 15, font: .light), textAligment: .left)
        return label
    }()
    
    private lazy var passwordErrorImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "loginFieldError"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var loginErrorTextLabel: UILabel = {
        let label = UILabel()
        label.configure(textColor: .red, font: .poppinsFont(ofSize: 15, font: .light), textAligment: .center, numberOfLines: 0)
        return label
    }()
    
    private let forgotButton: UIButton = {
        let button = UIButton()
        button.configure(title: "Forgot password?",
                         titleColor: UIColor.accentGreen,
                         font: .poppinsFont(ofSize: 17, font: .semibold))
        return button
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton()
        button.configure(title: "Log In", titleColor: .white,
                         font: .poppinsFont(ofSize: 17, font: .semibold),
                         backgroundColor: UIColor.accentGreen2,
                         cornerRadius: 26)
        return button
    }()
    
    
    private let disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureConstraints()
        configureObservables()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureConstraints() {
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        logoView.addSubviews(welcomeLabel, loginLabel)
        contentView.addSubviews(logoView, emailLabel, emailTextField, emailErrorStackView, passwordLabel, passwordTextField, eyeButton, passwordErrorStackView, loginErrorTextLabel, forgotButton, loginButton)
        emailErrorStackView.addArrangedSubviews( emailErrorImageView, emailErrorTextLabel)
        passwordErrorStackView.addArrangedSubviews(passwordErrorImageView, passwordErrorTextLabel)
        
        scrollView.addConstraints(top: safeAreaLayoutGuide.topAnchor,
                                  leading: safeAreaLayoutGuide.leadingAnchor,
                                  trailing: safeAreaLayoutGuide.trailingAnchor,
                                  bottom: safeAreaLayoutGuide.bottomAnchor)
        contentView.addConstraints(top: scrollView.contentLayoutGuide.topAnchor,
                                  leading: scrollView.contentLayoutGuide.leadingAnchor,
                                  trailing: scrollView.contentLayoutGuide.trailingAnchor,
                                  bottom: scrollView.contentLayoutGuide.bottomAnchor)
        
        let contentViewCenterY = contentView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor)
        contentViewCenterY.priority = .defaultLow
        
        let contentViewHeight = contentView.heightAnchor.constraint(equalTo: safeAreaLayoutGuide.heightAnchor)
        contentViewHeight.priority = .defaultLow
        
        NSLayoutConstraint.activate([
            contentView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            contentViewCenterY,
            contentViewHeight
        ])
        
        logoView.addConstraints(top: contentView.topAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, bottom: contentView.centerYAnchor, bottomPadding: 100)
        loginLabel.addConstraints(leading: contentView.leadingAnchor, bottom: logoView.bottomAnchor, leadingPadding: 32, bottomPadding: 28)
        welcomeLabel.addConstraints(leading: contentView.leadingAnchor, bottom: loginLabel.topAnchor, leadingPadding: 32, bottomPadding: 10)
        emailLabel.addConstraints(top: logoView.bottomAnchor, leading: contentView.leadingAnchor, leadingPadding: 32)
        emailTextField.addConstraints(top: emailLabel.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, topPadding: 8, leadingPadding: 32, trailingPadding: 32, height: 52)
        emailErrorStackView.addConstraints(top: emailTextField.bottomAnchor, leading: emailTextField.leadingAnchor, trailing: emailTextField.trailingAnchor)
        emailErrorImageView.addConstraints(width: 24, height: 24)
        passwordLabel.addConstraints(top: emailErrorStackView.bottomAnchor, leading: contentView.leadingAnchor, topPadding: 8, leadingPadding: 32)
        passwordTextField.addConstraints(top: passwordLabel.bottomAnchor, leading: emailTextField.leadingAnchor, trailing: emailTextField.trailingAnchor, topPadding: 8, height: 52)
        passwordErrorImageView.addConstraints(width: 24, height: 24)
        eyeButton.addConstraints(trailing: passwordTextField.trailingAnchor, trailingPadding: 10, width: 32, height: 32, centerY: passwordTextField)
        passwordErrorStackView.addConstraints(top: passwordTextField.bottomAnchor, leading: passwordTextField.leadingAnchor, trailing: passwordTextField.trailingAnchor)
        loginErrorTextLabel.addConstraints(top: passwordTextField.bottomAnchor, leading: passwordTextField.leadingAnchor, trailing: passwordTextField.trailingAnchor, topPadding: 8)
        forgotButton.addConstraints(top: loginErrorTextLabel.bottomAnchor, trailing: contentView.trailingAnchor, topPadding: 12, trailingPadding: 32)
        loginButton.addConstraints(leading: emailTextField.leadingAnchor, trailing: emailTextField.trailingAnchor, bottom: contentView.bottomAnchor, bottomPadding: 8, height: 52)
    }
    
    private func configureObservables() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        eyeButton.rx.tap.subscribe(onNext: { [weak self] in
            self?.showPasswordToggle()
        }).disposed(by: disposeBag)
        
        loginButton.rx.tap.subscribe(onNext: { [weak self] in
            guard let login = self?.emailTextField.text, let password = self?.passwordTextField.text else { return }
            self?.events.onNext(.loginPressed(login: login, password: password))
        }).disposed(by: disposeBag)
        
        forgotButton.rx.tap.subscribe(onNext: { [weak self] in
            self?.events.onNext(.forgotPressed)
        }).disposed(by: disposeBag)
    }
    
    private func showPasswordToggle() {
        passwordTextField.isSecureTextEntry.toggle()
        eyeButton.tintColor = passwordTextField.isSecureTextEntry ? .gray1 : .black
    }
    
    func configureView(with state: LoginInput) {
        emailErrorTextLabel.text = state.emailError
        let emailError = state.emailError != nil || state.loginFailed != nil
        emailTextField.layer.borderColor = emailError ? UIColor.red.cgColor : UIColor.gray.cgColor
        emailErrorImageView.isHidden = state.emailError == nil
        emailErrorTextLabel.isHidden = state.emailError == nil
        
        passwordErrorTextLabel.text = state.passwordError
        let passwordError = state.passwordError != nil || state.loginFailed != nil
        passwordTextField.layer.borderColor = passwordError ? UIColor.red.cgColor : UIColor.gray.cgColor
        passwordErrorImageView.isHidden = state.passwordError == nil
        passwordErrorTextLabel.isHidden = state.passwordError == nil
        
        loginErrorTextLabel.text = state.loginFailed
    }
    
    @objc private func keyboardWillAppear(notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardRectangle.height, right: 0)
            
            scrollView.contentInset = contentInsets
        }
    }
    
    @objc private func keyboardWillDisappear(notification: Notification) {
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
        scrollView.contentOffset = .zero
    }
}

extension LoginView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField === emailTextField {
            events.onNext(.textFieldChanged(type: .login, text: nil))
        } else if textField === passwordTextField {
            events.onNext(.textFieldChanged(type: .password, text: nil))
        }
        return string != " "
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        /*if textField === emailTextField, let text = textField.text {
            events.onNext(.textFieldChanged(type: .login, text: text))
        } else if textField === passwordTextField, let text = textField.text {
            events.onNext(.textFieldChanged(type: .password, text: text))
        }*/
    }
}

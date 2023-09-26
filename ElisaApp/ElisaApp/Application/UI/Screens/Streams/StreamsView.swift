//
//  StreamsView.swift
//  ElisaApp
//
//  Created by Mikhail Sein on 22.03.2022.
//

import UIKit
import RxSwift
import RxCocoa
import WebKit
import AVFoundation

final class StreamsView: UIView {
    
    // MARK: - Public Properties
    
    let events = PublishSubject<StreamsEvent>()
    
    // MARK: - Private Properties
    
    private var titleStackViewLeadingConstraint: NSLayoutConstraint!
    private var lastReceivedState: StreamsProviderState.StreamState?
    private var topBrightnessSliderConstraint: NSLayoutConstraint!
    private var bottomBrightnessSliderConstraint: NSLayoutConstraint!
    private var heightBrightnessSliderConstraint: NSLayoutConstraint!
    
    private lazy var loadingView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.backgroundColor = .black.withAlphaComponent(0.8)
        view.color = .white
        view.stopAnimating()
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var topGradientLayer: CALayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor.black.withAlphaComponent(0.7).cgColor,
            UIColor.clear.cgColor
        ]
        return layer
    }()
    
    private var webView: WKWebView!
    
    private lazy var bottomGradientLayer: CALayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.7).cgColor
        ]
        return layer
    }()
    
    private lazy var backButton: BlurredButton = {
        let button = BlurredButton()
        button.layer.cornerRadius = 18.0
        button.setImage(image: UIImage(named: "nav_back"))
        button.imageViewIndent = 5.0
        return button
    }()
    private var backButtonWidthConstraint: NSLayoutConstraint?
    
    private lazy var titleStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        return stackView
    }()
    
    private lazy var campaignTitleLabel: UILabel = {
        let label = UILabel()
        label.configure(textColor: .white, font: .poppinsFont(ofSize: 17, font: .bold))
        return label
    }()
    
    private lazy var streamTimeLabel: UILabel = {
        let label = UILabel()
        label.configure(textColor: .white, font: .poppinsFont(ofSize: 15, font: .regular))
        return label
    }()
    
    private lazy var statisticLabel: UILabel = {
        let label = UILabel()
        label.configure(textColor: .white, font: .poppinsFont(ofSize: 13, font: .regular))
        label.numberOfLines = 0
        label.isHidden = true
        label.backgroundColor = .clear
#if DEV || TEST
        label.isHidden = false
#endif
        return label
    }()
    
    private lazy var startButton: LoadingButton = {
        let button = LoadingButton()
        button.isLoading = false
        button.configure(title: "Start stream", titleColor: UIColor.accentGreen2, font: .poppinsFont(ofSize: 17, font: .semibold), backgroundColor: UIColor.white, cornerRadius: 26)
        return button
    }()
    
    private lazy var permissionsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 40
        return stackView
    }()
    
    private lazy var permissionsLabel: UILabel = {
        let label = UILabel()
        label.configure(text: "This app requires access to the camera and microphone for streaming", textColor: .white, font: .poppinsFont(ofSize: 20, font: .regular), textAligment: .center, numberOfLines: 0)
        return label
    }()
    
    private lazy var settingsButton: UIButton = {
        let button = UIButton()
        button.configure(title: "Open settings", titleColor: .black, font: .poppinsFont(ofSize: 16, font: .regular), backgroundColor: .white, cornerRadius: 12)
        return button
    }()
    
    private lazy var endButton: UIButton = {
        let button = UIButton()
        button.configure(tintColor: .white, image: UIImage(named: "logout"), backgroundColor: .lightRed, cornerRadius: 24)
        button.isHidden = true
        return button
    }()
    
    private lazy var rightPanelStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        return stackView
    }()
    
    private lazy var prepareStreamView: StreamPrepareView = {
        let view = StreamPrepareView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var camSwitchButton: BlurredButton = {
        let button = BlurredButton()
        button.layer.cornerRadius = 24.0
        button.setImage(image: UIImage(named: "camSwitch"))
        button.imageViewIndent = 12.0
        return button
    }()
    
    private lazy var micSwitchButton: BlurredButton = {
        let button = BlurredButton()
        button.layer.cornerRadius = 24.0
        button.setImage(image: UIImage(named: "mic"))
        button.imageViewIndent = 10.0
        return button
    }()
    
    private lazy var brightnessControl: BrightnessView = {
        let view = BrightnessView()
        view.setValue(frontBrightness)
        return view
    }()
    
    private lazy var errorTostLabel: ErrorTostLabel = {
        let error = ErrorTostLabel()
        error.translatesAutoresizingMaskIntoConstraints = false
        error.layer.cornerRadius = 12.0
        error.layer.masksToBounds = true
        return error
    }()
    
    private lazy var responderView: ResponderView = {
        let view = ResponderView()
        view.isUserInteractionEnabled = false
        return view
    }()
    
    private lazy var localStreamContainer = UIView()
    private var localStreamView: UIView?
	private var localStreamLayer: AVCaptureVideoPreviewLayer?
    private var callStartDate: Date?
    private var callTimeTimer: Timer?
    private var hideControlsTimer: Timer?
    private var isControlsHidden = false
    private var frontSelected = true
    private var frontBrightness = 0.5
    private var backBrightness = 0.5
    private var streamStarted = false
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureView()
        configureObservables()
        configureCallTimeTimer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        callTimeTimer?.invalidate()
        callTimeTimer = nil
        
        hideControlsTimer?.invalidate()
        hideControlsTimer = nil
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        configureConstraints()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let gradientSize = CGSize(width: bounds.width, height: 230)
        topGradientLayer.frame = CGRect(origin: .zero, size: gradientSize)
        bottomGradientLayer.frame = CGRect(origin: CGPoint(x: 0, y: bounds.height - gradientSize.height), size: gradientSize)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isControlsHidden {
            setControlsHidden(false)
            configureControlsTimer()
        } else {
            hideControlsTimer?.invalidate()
            setControlsHidden(true)
        }
    }
    
    // MARK: - Private Methods
    
    private func createWebView() -> WKWebView {
        let preferences = WKWebpagePreferences()
        if #available(iOS 14.0, *) {
            preferences.allowsContentJavaScript = true
            preferences.preferredContentMode = .mobile
        } else {
            // Fallback on earlier versions
        }
        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences = preferences
        
        let webView =  WKWebView(frame: .zero, configuration: config)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.isOpaque = false
        webView.backgroundColor = UIColor.clear
        webView.scrollView.backgroundColor = UIColor.clear
        webView.isUserInteractionEnabled = false
        webView.isHidden = true
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.navigationDelegate = self
        return webView
    }
    
    private func configureView() {
        backgroundColor = UIColor(displayP3Red: 0.15, green: 0.15, blue: 0.15, alpha: 1)
        addSubview(localStreamContainer)
        layer.addSublayer(topGradientLayer)
        layer.addSublayer(bottomGradientLayer)
        
        webView = createWebView()
        
        titleStackView.addArrangedSubviews(campaignTitleLabel, streamTimeLabel)
        permissionsStackView.addArrangedSubviews(permissionsLabel, settingsButton)
        rightPanelStackView.addArrangedSubviews(camSwitchButton, micSwitchButton)
        addSubviews(webView,
                    prepareStreamView,
                    backButton,
                    titleStackView,
                    permissionsStackView,
                    startButton,
                    endButton,
                    brightnessControl,
                    rightPanelStackView,
                    responderView,
                    loadingView,
                    errorTostLabel,
                    statisticLabel)
    }
    
    private func configureConstraints() {
        titleStackViewLeadingConstraint = titleStackView.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 8)
        responderView.addConstraints(to: self)
        localStreamContainer.addConstraints(to: self)
        webView.addConstraints(to: self)
        if let superview = superview {
            backButton.addConstraints(top: superview.safeAreaLayoutGuide.topAnchor, leading: leadingAnchor, topPadding: 12, leadingPadding: 16, heightAnchor: backButton.widthAnchor)
            webView.addConstraints(top: superview.safeAreaLayoutGuide.topAnchor, leading: leadingAnchor, trailing: trailingAnchor, bottom: bottomAnchor)
            backButtonWidthConstraint = backButton.widthAnchor.constraint(equalToConstant: 36)
            backButtonWidthConstraint?.isActive = true
            startButton.addConstraints(leading: leadingAnchor, trailing: trailingAnchor, bottom: superview.safeAreaLayoutGuide.bottomAnchor, leadingPadding: 32, trailingPadding: 32, bottomPadding: 32, height: 52)
            endButton.addConstraints(trailing: trailingAnchor, bottom: superview.safeAreaLayoutGuide.bottomAnchor, trailingPadding: 16, bottomPadding: 32, width: 48, height: 48)
            rightPanelStackView.addConstraints(top: superview.safeAreaLayoutGuide.topAnchor, trailing: trailingAnchor, topPadding: 12, trailingPadding: 16, width: 48)
        }
        titleStackView.addConstraints(trailing: rightPanelStackView.leadingAnchor, trailingPadding: 8, centerY: backButton)
        titleStackViewLeadingConstraint.isActive = true
        settingsButton.addConstraints(height: 40)
        permissionsStackView.addConstraints(widthAnchor: widthAnchor, widthAnchorMultiplier: 0.7, centerX: self, centerY: self)
        camSwitchButton.addConstraints(height: 48)
        micSwitchButton.addConstraints(height: 48)
        brightnessControl.addConstraints(trailing: trailingAnchor, trailingPadding: 16, width: 48)
        topBrightnessSliderConstraint = brightnessControl.topAnchor.constraint(equalTo: rightPanelStackView.bottomAnchor, constant: 32)
        topBrightnessSliderConstraint.isActive = true
        heightBrightnessSliderConstraint = brightnessControl.heightAnchor.constraint(equalToConstant: 160)
        heightBrightnessSliderConstraint.isActive = true
        bottomBrightnessSliderConstraint = brightnessControl.bottomAnchor.constraint(equalTo: endButton.topAnchor, constant: -8)
        bottomBrightnessSliderConstraint.isActive = false
        loadingView.addConstraints(top: topAnchor, leading: leadingAnchor, trailing: trailingAnchor, bottom: bottomAnchor)
        errorTostLabel.addConstraints(leading: leadingAnchor, trailing: trailingAnchor, bottom: startButton.topAnchor, leadingPadding: 32, trailingPadding: 32, bottomPadding: 10)
        statisticLabel.addConstraints(top: backButton.bottomAnchor,
                                      leading: leadingAnchor,
                                      topPadding: 10,
                                      leadingPadding: 32,
                                      width: 250)
        prepareStreamView.addConstraints(to: self)
    }
    
    private func configureObservables() {
        backButton.rx.tap.subscribe(onNext: { [weak self] in
            self?.events.onNext(.backPressed)
            
        }).disposed(by: disposeBag)
        
        settingsButton.rx.tap.subscribe(onNext: { [weak self] in
            self?.events.onNext(.settingsPressed)
        }).disposed(by: disposeBag)
        
        startButton.rx.tap.subscribe(onNext: { [weak self] in
            self?.events.onNext(.startPressed)
        }).disposed(by: disposeBag)
        
        endButton.rx.tap.subscribe(onNext: { [weak self] in
            self?.events.onNext(.endPressed)
        }).disposed(by: disposeBag)
        
        camSwitchButton.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            self.frontSelected.toggle()
            let brightness = self.frontSelected ? self.frontBrightness : self.backBrightness
            self.brightnessControl.setValue(brightness)
            self.events.onNext(.camSwitchPressed)
            self.events.onNext(.brightnessChanged(brightness))
        }).disposed(by: disposeBag)
        
        responderView.onTouchEvent.subscribe(onNext: { [weak self] _ in
            self?.configureControlsTimer()
        }).disposed(by: disposeBag)
        
        brightnessControl.onValueChanged = { [weak self] value in
            guard let self = self else { return }
            self.events.onNext(.brightnessChanged(value))
            if self.frontSelected {
                self.frontBrightness = value
            } else {
                self.backBrightness = value
            }
            self.configureControlsTimer()
        }
        micSwitchButton.rx.tap.subscribe(onNext: { [weak self] in
            self?.events.onNext(.micButtonTapped)
        }).disposed(by: disposeBag)
        NotificationCenter.default.rx.notification(UIDevice.orientationDidChangeNotification).subscribe(onNext: { [weak self] _ in
            self?.layoutBrightnessSlider()
        }).disposed(by: disposeBag)
    }
    
    private func configureCallTimeTimer() {
        callTimeTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [weak self] _ in
            guard let self = self, let startDate = self.callStartDate else { return }
            let duration = Date().timeIntervalSince1970 - startDate.timeIntervalSince1970
            let rawSeconds = max(duration, 0)
            let hours = floor(rawSeconds / 3600)
            let minutes = floor((rawSeconds / 60).truncatingRemainder(dividingBy: 60))
            let seconds = floor(rawSeconds.truncatingRemainder(dividingBy: 60))
            self.streamTimeLabel.text = String(format: "%02.0f:%02.0f:%02.0f", hours, minutes, seconds)
        })
        callTimeTimer?.tolerance = 0.1
    }
    
    private func configureControlsTimer() {
        guard streamStarted else { return }
        hideControlsTimer?.invalidate()
        
        hideControlsTimer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true, block: { [weak self] _ in
            self?.setControlsHidden(true)
        })
        hideControlsTimer?.tolerance = 0.1
    }
    
    private func setControlsHidden(_ isHidden: Bool) {
        guard streamStarted else { return }
        UIView.animate(withDuration: 0.5) {
            self.backButton.alpha = isHidden ? 0 : 1
            self.titleStackView.alpha = isHidden ? 0 : 1
            self.endButton.alpha = isHidden ? 0 : 1
            self.rightPanelStackView.alpha = isHidden ? 0 : 1
            self.brightnessControl.alpha = isHidden ? 0 : 1
        } completion: { _ in
            self.isControlsHidden = isHidden
        }
    }
    
    private func layoutBrightnessSlider() {
        switch lastReceivedState {
        case .initiated, .failed, .connecting:
            switch UIDevice.current.orientation {
            case .portrait:
                bottomBrightnessSliderConstraint.isActive = false
                heightBrightnessSliderConstraint.isActive = true
                topBrightnessSliderConstraint.constant = 32.0
            case .landscapeLeft, .landscapeRight:
                heightBrightnessSliderConstraint.isActive = false
                bottomBrightnessSliderConstraint.isActive = true
                topBrightnessSliderConstraint.constant = 8.0
            default:
                break
            }
        case .started, .preparing, .finished, .waiting, .none:
            break
        }
    }
    
    // MARK: - Public Methods
    
    func configureView(with input: StreamsInput) {
        guard let campaign = input.campaign else { return }
        
        campaignTitleLabel.text = campaign.name
        statisticLabel.text = input.statistic
        
        switch input.micState {
        case .mute:
            micSwitchButton.setImage(image: UIImage(named: "micOff"))
        case .unmute:
            micSwitchButton.setImage(image: UIImage(named: "mic"))
        }
        
        let permissionsGranted = input.micGranted != false && input.cameraGranted != false
        startButton.isHidden = !permissionsGranted
        permissionsStackView.isHidden = permissionsGranted
        
        if let localStreamView = input.localStreamView {
            if self.localStreamView !== localStreamView {
                self.localStreamView = localStreamView
                localStreamContainer.addSubview(localStreamView)
                self.localStreamView?.addConstraints(to: localStreamContainer)
                self.localStreamView?.center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
                
            }
        } else {
            localStreamView?.removeFromSuperview()
            localStreamView = nil
        }
        
		if let localStreamLayer = input.localStreamLayer {
			if self.localStreamLayer !== localStreamLayer {
				self.localStreamLayer = localStreamLayer
				localStreamContainer.layer.addSublayer(localStreamLayer)
				localStreamLayer.frame = localStreamContainer.bounds
			}
		} else {
			localStreamLayer?.removeFromSuperlayer()
			localStreamLayer = nil
		}
		
		localStreamContainer.isHidden = (localStreamView == nil && localStreamLayer == nil) || input.cameraGranted != true
        
        if input.shouldReloadOverlay,
           let url = input.overlayUrl {
            DispatchQueue.main.async {
                self.webView.stopLoading()
                self.webView.load(URLRequest(url: url))
            }
        }
                
        switch input.streamState {
        case .initiated, .failed:
            layoutBrightnessSlider()
            prepareStreamView.isHidden = true
            streamTimeLabel.isHidden = true
            if let url = input.overlayUrl {
                DispatchQueue.main.async {
                    self.webView.stopLoading()
                    self.webView.load(URLRequest(url: url))
                }
                startButton.setTitle("Start stream", for: .normal)
                startButton.isEnabled = true
            }
            webView.isHidden = false
            if let error = input.streamError {
                
                switch error {
                case .notScheduled:
                    break
                case .waitingTimeout:
                    errorTostLabel.isHidden = false
                    errorTostLabel.configure(text: error.rawValue)
                }
                
            } else {
                errorTostLabel.isHidden = true
            }
            
        case .preparing, .connecting:
            startButton.isHidden = true
            prepareStreamView.isHidden = false
            errorTostLabel.isHidden = true

            if let error = input.streamError {
                switch error {
                case .notScheduled:
                    prepareStreamView.configure(descriptionText: error.rawValue)
                case .waitingTimeout:
                    break
                }
            }
            
        case .started(let startDate):
            startButton.isHidden = true
            if lastReceivedState != .started(startDate) {
                prepareStreamView.isHidden = true
                loadingView.isHidden = true
                loadingView.stopAnimating()
                streamStarted = true
                responderView.isUserInteractionEnabled = true
                
                configureControlsTimer()
                
                callStartDate = startDate
                streamTimeLabel.isHidden = false
                endButton.isHidden = false
                backButton.isHidden = true
                titleStackViewLeadingConstraint.constant = -36
                errorTostLabel.isHidden = true
            }
        case .finished:
            prepareStreamView.isHidden = true
            setControlsHidden(false)
            streamStarted = false
            hideControlsTimer?.invalidate()
            callTimeTimer?.invalidate()
            startButton.isHidden = true
            endButton.isHidden = true
            loadingView.isHidden = true
            loadingView.stopAnimating()
            webView.stopLoading()
            webView.isHidden = true
            
        case .waiting:
            prepareStreamView.isHidden = true
            loadingView.isHidden = false
            loadingView.startAnimating()
            startButton.isHidden = true
        }
        lastReceivedState = input.streamState
    }
}

extension StreamsView: WKNavigationDelegate {
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        DispatchQueue.main.async {
            webView.reload()
        }
    }
}

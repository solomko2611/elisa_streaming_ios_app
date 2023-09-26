//
//  StreamsViewController.swift
//  ElisaApp
//
//  Created by Mikhail Sein on 22.03.2022.
//

import UIKit
import RxSwift

final class StreamsViewController: BaseViewController {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var shouldAutorotate: Bool {
        switch streamState {
        case .initiated, .failed, .connecting:
            return true
        case .started, .preparing, .finished, .waiting:
            return false
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        switch streamState {
        case .initiated, .failed, .connecting:
            return [.portrait, .landscape]
        case .started, .preparing, .finished, .waiting:
            if let currentOritentation = self.view.window?.windowScene?.interfaceOrientation {
                switch currentOritentation {
                case .portrait:
                    return .portrait
                case .landscapeLeft:
                    return .landscapeLeft
                case .landscapeRight:
                    return .landscapeRight
                default:
                    break
                }
            }
            return .portrait
        }
    }
        
    // MARK: - Private Properties
    
    private let viewModel: StreamsViewModel
    private var disposeBag: DisposeBag?
    private var streamState: StreamsProviderState.StreamState = .initiated {
        didSet {
            if streamState != oldValue {
                if #available(iOS 16.0, *) {
                    setNeedsUpdateOfSupportedInterfaceOrientations()
                } else {
                    // Fallback on earlier versions
                }
            }
        }
    }
    private let streamsView = StreamsView()
    
    // MARK: - Initializer
    
    init(viewModel: StreamsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterToBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - ViewController Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureConstraints()
        configureObservables()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        viewModel.events.onNext(.rotationEvent)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.events.onNext(.viewDidAppear)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel.events.onNext(.viewDidDisAppear)
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    // MARK: - Private Methods

    private func configureView() {
        view.addSubviews(streamsView)
    }
    
    private func configureObservables() {
        let disposeBag = DisposeBag()
        
        viewModel
            .input
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] data in
            self?.render(data: data)
        }).disposed(by: disposeBag)
        
        streamsView.events.subscribe(onNext: { [weak self] event in
            self?.viewModel.events.onNext(event)
        }).disposed(by: disposeBag)
        
        self.disposeBag = disposeBag
    }
    
    private func configureConstraints() {
        streamsView.addConstraints(to: view)
    }
    
    private func render(data: StreamsInput) {
        streamState = data.streamState
        streamsView.configureView(with: data)
    }
    
    //MARK: - ObjC
    
    @objc
    private func didEnterToBackground() {
        viewModel.events.onNext(.appDidEnterToBackground)
    }
    
    @objc
    private func didBecomeActive() {
        viewModel.events.onNext(.appDidBecomeActive)
    }
}

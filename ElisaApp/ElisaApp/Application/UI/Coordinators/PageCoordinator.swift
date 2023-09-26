//
//  PageCoordinator.swift
//  ElisaApp
//
//  Created by Mikhail Sein on 22.03.2022.
//

import DITranquillity
import UIKit
import RxSwift

final class PageCoordinator: BaseCoordinator, ErrorProcessing {
    
    private let container: DIContainer
    private let disposeBag = DisposeBag()
    let router: Router
    var onClose: (() -> Void)?
    
    init(router: Router, container: DIContainer) {
        self.router = router
        self.container = container
    }
    
    override func start() {
        showStreamList()
    }
    
    private func showStreamList() {
        let streamListDependency: PageListDependency = container.resolve()
        streamListDependency.viewModel.actionHandler = { [weak self] action in
            switch action {
            case .showStream(let campaign, let page):
                self?.showStream(with: campaign, page: page)
            case .logout(let completion):
                self?.showConfirmAlert(completion: completion)
            }
        }
        router.setRootModule(streamListDependency.viewController)
    }
    
    private func showConfirmAlert(completion: @escaping () -> Void) {
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            self.onClose?()
            completion()
        }

        self.showAlert(title: "Logout",
                       message: "Are you sure you want to log out?",
                       style: .alert,
                       actions: [okAction],
                       withCancelButton: true)
    }
    
    private func showStream(with campaign: Campaign, page: Page) {
        let dependency: StreamsDependency = container.resolve()
        
        let viewController = dependency.viewController
        viewController.modalPresentationStyle = .fullScreen
        
        let viewModel = dependency.viewModel
        viewModel.setCampaign(campaign, page: page)
        viewModel.output.subscribe(onNext: { [weak self] output in
            switch output {
            case .closeStream:
                self?.router.dismissModule()
            case .settingsPressed:
                if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            case .confirmLeave(let alert):
                self?.router.present(alert)
            case .showFailed:
                self?.router.dismissModule(animated: true, completion: {
                    self?.showAlert(
                        title: "Unable to start stream",
                        message: "Please try again later",
                        style: .alert,
                        actions: [
                            UIAlertAction(title: "OK", style: .default, handler: nil)
                        ],
                        withCancelButton: false
                    )
                })
            case .confirmStartStream(let alert):
                self?.router.present(alert)
            }
        }).disposed(by: disposeBag)
        
        router.present(viewController)
    }
}

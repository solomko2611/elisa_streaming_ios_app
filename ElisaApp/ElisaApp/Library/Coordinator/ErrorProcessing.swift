//
//  ErrorProcessing.swift
//  ForaArchitecture
//
//  Created by Mikhail Sein on 02.12.2021.
//

import UIKit

protocol ErrorProcessing: BaseCoordinator {
    var router: Router { get }
    
    func showAlert(title: String?, message: String?, style: UIAlertController.Style, actions: [UIAlertAction], withCancelButton: Bool)
    func processError(with error: Error)
}

extension ErrorProcessing {
    func processError(with error: Error) {
        showAlert(
            title: "Something was wrong",
            message: error.localizedDescription,
            style: .alert,
            actions: [
                UIAlertAction(title: "OK", style: .default, handler: nil)
            ]
        )
    }
    
    func showAlert(
        title: String? = nil,
        message: String? = nil,
        style: UIAlertController.Style = .alert,
        actions: [UIAlertAction],
        withCancelButton: Bool = false
    ) {
        DispatchQueue.main.async {
            let alert = UIAlertController(
                title: title,
                message: message,
                preferredStyle: style
            )
            actions.forEach {
                alert.addAction($0)
            }
            if withCancelButton {
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            }
            self.router.present(alert)
        }
    }
}

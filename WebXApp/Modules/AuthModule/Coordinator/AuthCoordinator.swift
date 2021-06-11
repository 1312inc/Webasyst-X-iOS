//
//  AuthCoordinator.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 10.06.2021.
//

import UIKit
import Webasyst

protocol AuthCoordinatorProtocol {
    func showErrorAlert(with: String)
    func openCodeScreen(_ phoneNumber: String)
}

final class AuthCoordinator: Coordinator, AuthCoordinatorProtocol {
    
    var childCoordinator: [Coordinator] = []
    var navigationController: UINavigationController
    
    init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let authViewController = AuthViewController()
        let authViewModel = AuthViewModel(self)
        authViewController.viewModel = authViewModel
        self.navigationController.pushViewController(authViewController, animated: true)
    }
    
    func showErrorAlert(with: String) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: NSLocalizedString("errorTitle", comment: ""), message: with, preferredStyle: .alert)
            let alertAction = UIAlertAction(title: NSLocalizedString("okAlert", comment: ""), style: .cancel)
            alertController.addAction(alertAction)
            self.navigationController.present(alertController, animated: true, completion: nil)
        }
    }
    
    func openCodeScreen(_ phoneNumber: String) {
        let coordinator = ConfirmCodeCoordinator(self.navigationController, phoneNumber: phoneNumber)
        coordinator.start()
    }
    
}

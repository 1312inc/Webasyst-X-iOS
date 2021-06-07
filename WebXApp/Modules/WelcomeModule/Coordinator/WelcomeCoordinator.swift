//
//  AuthCoordinator.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 1/13/21.
//

import UIKit
import Webasyst

protocol WelcomeCoordinatorProtocol: AnyObject {
    init(_ navigationController: UINavigationController)
    func showWebAuthModal()
    func showConnectionAlert()
}

final class WelcomeCoordinator: Coordinator, WelcomeCoordinatorProtocol {
    
    private(set) var childCoordinator: [Coordinator] = []
    private var navigationController: UINavigationController
    private let webasyst = WebasystApp()
    
    init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let welcomeViewController = WelcomeViewController()
        let welcomeCoordinator = WelcomeCoordinator(navigationController)
        let welcomeViewModel = WelcomeViewModel(coordinator: welcomeCoordinator)
        welcomeViewController.viewModel = welcomeViewModel
        self.navigationController.setViewControllers([welcomeViewController], animated: true)
    }
    
    func showWebAuthModal() {
        webasyst.oAuthLogin(navigationController: self.navigationController) { result in
            switch result {
            case .success:
                let appCoordinator = AppCoordinator(window: UIApplication.shared.windows.first ?? UIWindow())
                appCoordinator.start()
            case .error(error: let error):
                let alertController = UIAlertController(title: NSLocalizedString("errorTitle", comment: ""), message: error, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Ок", style: .cancel, handler: nil))
                self.navigationController.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    func showConnectionAlert() {
        let alertController = UIAlertController(title: NSLocalizedString("errorTitle", comment: ""), message: NSLocalizedString("connectionAlertMessage", comment: ""), preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ок", style: .cancel, handler: nil))
        self.navigationController.present(alertController, animated: true, completion: nil)
    }
    
}

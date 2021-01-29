//
//  AuthCoordinator.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 1/13/21.
//

import UIKit

protocol WelcomeCoordinatorProtocol: class {
    init(_ navigationController: UINavigationController)
    func showWebAuthModal()
    func showConnectionAlert()
}

final class WelcomeCoordinator: Coordinator, WelcomeCoordinatorProtocol {
    
    private(set) var childCoordinator: [Coordinator] = []
    private var navigationController: UINavigationController
    
    init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let welcomeViewController = WelcomeViewController()
        let welcomeCoordinator = WelcomeCoordinator(navigationController)
        let networkingHelper = NetworkingHelper()
        let welcomeViewModel = WelcomeViewModel(coordinator: welcomeCoordinator, networkingHelper: networkingHelper)
        welcomeViewController.viewModel = welcomeViewModel
        self.navigationController.setViewControllers([welcomeViewController], animated: true)
    }
    
    func showWebAuthModal() {
        let authCoordinator = AuthCoordinator(navigationController)
        childCoordinator.append(authCoordinator)
        authCoordinator.start()
    }
    
    func showConnectionAlert() {
        let alertController = UIAlertController(title: NSLocalizedString("errorTitle", comment: ""), message: NSLocalizedString("connectionAlertMessage", comment: ""), preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ок", style: .cancel, handler: nil))
        self.navigationController.present(alertController, animated: true, completion: nil)
    }
    
}

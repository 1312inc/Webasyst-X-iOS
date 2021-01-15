//
//  AuthWebCoordinator.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 1/13/21.
//

import UIKit

protocol AuthCoordinatorProtocol {
    init(_ navigationController: UINavigationController)
    func successAuth()
    func errorAuth()
}

class AuthCoordinator: Coordinator, AuthCoordinatorProtocol {
    
    private var navigationController: UINavigationController

    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    private(set) var childCoordinator: [Coordinator] = []
    
    func start() {
        let authViewController = AuthViewController()
        let authCoordinator = AuthCoordinator(self.navigationController)
        let networkingService = AuthNetworkingService()
        let authViewModel = AuthViewModel(networkingService: networkingService, coordinator: authCoordinator)
        authViewController.viewModel = authViewModel
        self.navigationController.present(authViewController, animated: true, completion: nil)
    }
    
    func successAuth() {
        self.navigationController.dismiss(animated: true, completion: nil)
        let firstViewController = VeniViewController()
        self.navigationController.setViewControllers([firstViewController], animated: true)
    }
    
    func errorAuth() {
        self.navigationController.dismiss(animated: true, completion: nil)
        let alertController = UIAlertController(title: "Ошибка", message: "Ошибка авторизации. Попробуйте повторить попытку позже", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ок", style: .cancel, handler: nil))
        self.navigationController.present(alertController, animated: true, completion: nil)
    }
    
}

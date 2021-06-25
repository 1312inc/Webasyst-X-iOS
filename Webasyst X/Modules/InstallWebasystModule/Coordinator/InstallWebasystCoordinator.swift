//
//  InstallWebasystCoordinator.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 18.06.2021.
//

import UIKit

protocol InstallWebasystCoordinatorProtocol {
    func openInstructionWaid()
    func startInModalSheet()
    func showAlert(title: String, message: String)
}

final class InstallWebasystCoordinator: Coordinator, InstallWebasystCoordinatorProtocol {
    
    var childCoordinator: [Coordinator] = []
    private var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewController = InstallWebasystViewController()
        let viewModel = InstallWebasystViewModel(coordinator: self)
        viewController.viewModel = viewModel
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    func startInModalSheet() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50)) {
            let viewController = InstallWebasystViewController()
            let viewModel = InstallWebasystViewModel(coordinator: self)
            viewController.viewModel = viewModel
            self.navigationController.present(viewController, animated: true, completion: nil)
        }
    }
    
    func openInstructionWaid() {
        let coordinator = WaidInstructionCoordinator(self.navigationController)
        coordinator.start()
    }
    
    func showAlert(title: String, message: String) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.navigationController.present(alertController, animated: true, completion: nil)
        }
    }
    
}

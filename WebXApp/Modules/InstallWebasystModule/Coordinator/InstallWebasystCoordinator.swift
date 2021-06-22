//
//  InstallWebasystCoordinator.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 18.06.2021.
//

import UIKit

protocol InstallWebasystCoordinatorProtocol {
    func openInstructionWaid()
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
    
    func openInstructionWaid() {
        let coordinator = WaidInstructionCoordinator(self.navigationController)
        coordinator.start()
    }
    
}

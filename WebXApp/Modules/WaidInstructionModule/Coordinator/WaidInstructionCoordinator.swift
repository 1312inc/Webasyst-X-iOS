//
//  File.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 18.06.2021.
//

import UIKit

protocol WaidInstructionCoordinatorProtocol {
    
}

final class WaidInstructionCoordinator: Coordinator, WaidInstructionCoordinatorProtocol {
    
    var childCoordinator: [Coordinator] = []
    private var navigationController: UINavigationController
    
    init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewController = WaidInstructionViewController()
        let viewModel = WaidInstructionViewModel(coordinator: self)
        viewController.viewModel = viewModel
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
}

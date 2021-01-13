//
//  AuthWebCoordinator.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 1/13/21.
//

import UIKit

protocol AuthCoordinatorProtocol {
    init(_ navigationController: UINavigationController)
}

class AuthCoordinator: Coordinator, AuthCoordinatorProtocol {
    
    private var navigationController: UINavigationController

    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    private(set) var childCoordinator: [Coordinator] = []
    
    func start() {
        let authViewController = AuthViewController()
        self.navigationController.present(authViewController, animated: true, completion: nil)
    }
    
}

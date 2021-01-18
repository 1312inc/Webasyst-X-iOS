//
//  ShopCoordinator.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 1/18/21.
//

import UIKit

protocol ShopCoordinatorProtocol {
    init(_ navigationController: UINavigationController)
}

class ShopCoordinator: Coordinator, ShopCoordinatorProtocol {
    private var navigationController: UINavigationController
    var childCoordinator: [Coordinator] = []
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let shopViewController = ShopViewController()
        self.navigationController.setViewControllers([shopViewController], animated: true)
    }
    
}

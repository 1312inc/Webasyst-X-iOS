//
//  ShopCoordinator.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 1/18/21.
//

import UIKit

protocol ShopCoordinatorProtocol {
    init(_ navigationController: UINavigationController)
    func openInstallList()
}

class ShopCoordinator: Coordinator, ShopCoordinatorProtocol {
    private var navigationController: UINavigationController
    var childCoordinator: [Coordinator] = []
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let shopNetworkingService = ShopNetworkingService()
        let shopViewModel = ShopViewModel(shopNetworkingService, coordinator: self)
        let shopViewController = ShopViewController()
        shopViewController.viewModel = shopViewModel
        self.navigationController.setViewControllers([shopViewController], animated: true)
    }
    
    //Opening install list
    func openInstallList() {
        let installListCoordinator = InstallListCoordinator(navigationController)
        childCoordinator.append(installListCoordinator)
        installListCoordinator.start()
    }
    
}

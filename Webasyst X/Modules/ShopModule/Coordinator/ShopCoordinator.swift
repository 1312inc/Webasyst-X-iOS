//
//  ShopCoordinator.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 1/18/21.
//

import UIKit
import Moya

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
        let moyaProvider = MoyaProvider<NetworkingService>()
        let shopViewModel = ShopViewModel(moyaProvider: moyaProvider)
        let shopViewController = ShopViewController()
        shopViewController.viewModel = shopViewModel
        shopViewController.coordinator = self
        self.navigationController.setViewControllers([shopViewController], animated: true)
    }
    
    //Opening install list
    func openInstallList() {
        let installListCoordinator = InstallListCoordinator(navigationController)
        childCoordinator.append(installListCoordinator)
        installListCoordinator.start()
    }
    
}

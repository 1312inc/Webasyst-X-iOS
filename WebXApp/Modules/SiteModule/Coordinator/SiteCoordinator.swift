//
//  SiteCoordinator.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 1/18/21.
//

import UIKit

protocol SiteCoordinatorProtocol {
    init(_ navigationController: UINavigationController)
    func openInstallList()
}

class SiteCoordinator: Coordinator, SiteCoordinatorProtocol {
    private var navigationController: UINavigationController
    var childCoordinator: [Coordinator] = []
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let siteViewController = SiteViewController()
        let viewModel = SiteViewModel(coordinator: self)
        siteViewController.viewModel = viewModel
        self.navigationController.setViewControllers([siteViewController], animated: true)
    }
    
    //Opening install list
    func openInstallList() {
        let installListCoordinator = InstallListCoordinator(navigationController)
        childCoordinator.append(installListCoordinator)
        installListCoordinator.start()
    }
    
}

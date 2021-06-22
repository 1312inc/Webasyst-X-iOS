//
//  SiteCoordinator.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 1/18/21.
//

import UIKit

protocol SiteCoordinatorProtocol {
    init(_ navigationController: UINavigationController)
}

class SiteCoordinator: Coordinator, SiteCoordinatorProtocol {
    private var navigationController: UINavigationController
    var childCoordinator: [Coordinator] = []
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let siteViewController = SiteViewController()
        self.navigationController.setViewControllers([siteViewController], animated: true)
    }
    
}

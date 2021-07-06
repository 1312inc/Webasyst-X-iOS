//
//  SiteCoordinator.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 1/18/21.
//

import UIKit
import Moya

protocol SiteCoordinatorProtocol {
    init(_ navigationController: UINavigationController)
    func openInstallList()
    func openDetail(pageId: String)
}

class SiteCoordinator: Coordinator, SiteCoordinatorProtocol {
    private var navigationController: UINavigationController
    var childCoordinator: [Coordinator] = []
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let siteViewController = SiteViewController()
        let moyaProvider = MoyaProvider<NetworkingService>()
        let viewModel = SiteViewModel(moyaProvider: moyaProvider)
        siteViewController.viewModel = viewModel
        siteViewController.coordinator = self
        self.navigationController.setViewControllers([siteViewController], animated: true)
    }
    
    //Opening install list
    func openInstallList() {
        let installListCoordinator = InstallListCoordinator(navigationController)
        childCoordinator.append(installListCoordinator)
        installListCoordinator.start()
    }
    
    func openDetail(pageId: String) {
        let coordinator = DetailSiteCoordinator(navigationController: self.navigationController, pageId: pageId)
        coordinator.start()
    }
    
}

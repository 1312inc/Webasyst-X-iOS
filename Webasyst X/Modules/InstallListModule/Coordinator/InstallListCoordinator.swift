//
//  InstallListCoordinator.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 1/18/21.
//

import UIKit

protocol InstallListCoordinatorProtocol {
    init(_ navigationController: UINavigationController)
    func dismissInstallList()
    func openAddWebasyst()
}

class InstallListCoordinator: Coordinator, InstallListCoordinatorProtocol {
    
    private var navigationController: UINavigationController
    var childCoordinator: [Coordinator] = []
    private var installListNavigationController = UINavigationController()
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let installListViewModel = InstallListViewModel(coordinator: self)
        let installListViewController = InstallListViewController()
        installListViewController.viewModel = installListViewModel
        installListNavigationController = UINavigationController(rootViewController: installListViewController)
        self.navigationController.present(installListNavigationController, animated: true, completion: nil)
    }
    
    func dismissInstallList() {
        self.navigationController.dismiss(animated: true, completion: nil)
    }
    
    func openAddWebasyst() {
        let installWebasystCoordinator = InstallWebasystCoordinator(navigationController: self.installListNavigationController)
        installWebasystCoordinator.start()
    }
    
}

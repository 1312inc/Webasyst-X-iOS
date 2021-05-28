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
}

class InstallListCoordinator: Coordinator, InstallListCoordinatorProtocol {
    
    private var navigationController: UINavigationController
    var childCoordinator: [Coordinator] = []
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let installListViewModel = InstallListViewModel(coordinator: self)
        let installListViewController = InstallListViewController()
        installListViewController.viewModel = installListViewModel
        let installListNavigationController = UINavigationController(rootViewController: installListViewController)
        self.navigationController.present(installListNavigationController, animated: true, completion: nil)
    }
    
    func dismissInstallList() {
        self.navigationController.dismiss(animated: true, completion: nil)
    }
    
}

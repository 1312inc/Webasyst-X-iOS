//
//  InstallListCoordinator.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 1/18/21.
//

import UIKit

protocol InstallListCoordinatorProtocol {
    init(_ navigationController: UINavigationController, line: Int, function: String)
    func dismissInstallList()
    func openAddWebasyst()
}

class InstallListCoordinator: Coordinator, InstallListCoordinatorProtocol {
    
    private var navigationController: UINavigationController
    var childCoordinator: [Coordinator] = []
    private var installListNavigationController = UINavigationController()
    var installListViewController: InstallListViewController?
    var installListViewModel: InstallListViewModel?
    
    required init(_ navigationController: UINavigationController, line: Int = #line, function: String = #function) {
        self.navigationController = navigationController
        print("coordinator", line, function)
    }
    
    deinit {
        print("coordinator deinit")
    }
    
    func start() {
        installListViewModel = InstallListViewModel(coordinator: self)
        installListViewController = InstallListViewController()
        installListViewController?.viewModel = installListViewModel
        installListNavigationController = UINavigationController(rootViewController: installListViewController ?? UIViewController())
        self.navigationController.present(installListNavigationController, animated: true, completion: nil)
    }
    
    func dismissInstallList() {
        installListViewModel = nil
        self.installListViewController = nil
        self.navigationController.dismiss(animated: true, completion: nil)
    }
    
    func openAddWebasyst() {
        let installWebasystCoordinator = InstallWebasystCoordinator(navigationController: self.installListNavigationController)
        installWebasystCoordinator.start()
    }
    
}

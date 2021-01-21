//
//  BlogCoordinator.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 1/18/21.
//

import UIKit

protocol BlogCoordinatorProtocol {
    init(_ navigationController: UINavigationController)
    func openInstallList()
    func openProfileScreen()
}

class BlogCoordinator: Coordinator, BlogCoordinatorProtocol {
    
    private var navigationController: UINavigationController
    var childCoordinator: [Coordinator] = []
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let blogCoordinator = BlogCoordinator(self.navigationController)
        let blogNetworkingService = BlogNetworkingService()
        let blogViewModel = BlogViewModel(coordinator: blogCoordinator, blogNetworkingService: blogNetworkingService)
        let blogViewController = BlogViewController()
        blogViewController.viewModel = blogViewModel
        self.navigationController.setViewControllers([blogViewController], animated: true)
    }
    
    func openInstallList() {
        let installListCoordinator = InstallListCoordinator(navigationController)
        childCoordinator.append(installListCoordinator)
        installListCoordinator.start()
    }
    
    func openProfileScreen() {
        let profileCoordinator = ProfileCoordinator(self.navigationController)
        profileCoordinator.start()
    }
        
}

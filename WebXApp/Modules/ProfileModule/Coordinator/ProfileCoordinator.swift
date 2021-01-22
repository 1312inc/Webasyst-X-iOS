//
//  ProfileCoordinator.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 1/19/21.
//

import UIKit

protocol ProfileCoordinatorProtocol: class {
    init(_ navigationController: UINavigationController)
}

class ProfileCoordinator: Coordinator, ProfileCoordinatorProtocol {
    
    private var navigationController: UINavigationController
    var childCoordinator: [Coordinator] = []
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let profileDataService = ProfileDataService()
        let profileViewModel = ProfileViewModel(coordinator: self, profileDataService: profileDataService)
        let profileViewController = ProfileViewController()
        profileViewController.viewModel = profileViewModel
        self.navigationController.pushViewController(profileViewController, animated: true)
    }
    
}

//
//  BlogCoordinator.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 1/18/21.
//

import UIKit
import Webasyst

protocol BlogCoordinatorProtocol {
    init(_ navigationController: UINavigationController)
    func openInstallList()
    func openDetailBlogEntry(_ blogEntry: PostList)
}

class BlogCoordinator: Coordinator, BlogCoordinatorProtocol {
    
    private var navigationController: UINavigationController
    private var webasyst = WebasystApp()
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
        webasyst.getAllUserInstall({ userInstall in
            if let installs = userInstall {
                if installs.isEmpty {
                    let installCoordinator = InstallWebasystCoordinator(navigationController: self.navigationController)
                    installCoordinator.startInModalSheet()
                }
            }
        })
    }
    
    //Opening install list
    func openInstallList() {
        let installListCoordinator = InstallListCoordinator(navigationController)
        childCoordinator.append(installListCoordinator)
        installListCoordinator.start()
    }
    
    //Opening detail blog entry
    func openDetailBlogEntry(_ blogEntry: PostList) {
        let blogEntryCoordinator = BlogEntryCoordinator(self.navigationController, blogEntry: blogEntry)
        childCoordinator.append(blogEntryCoordinator)
        blogEntryCoordinator.start()
    }
}

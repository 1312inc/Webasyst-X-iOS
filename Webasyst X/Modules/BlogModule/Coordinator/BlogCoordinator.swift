//
//  BlogCoordinator.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 1/18/21.
//

import UIKit
import Webasyst
import Moya

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
        let moyaProvider = MoyaProvider<NetworkingService>()
        let blogViewModel = BlogViewModel(moyaProvider: moyaProvider)
        let blogViewController = BlogViewController()
        blogViewController.viewModel = blogViewModel
        blogViewController.coordinator = self
        self.navigationController.setViewControllers([blogViewController], animated: true)
    }
    
    //Opening install list
    func openInstallList() {
        let installListCoordinator = InstallListCoordinator(navigationController)
        installListCoordinator.start()
    }
    
    //Opening detail blog entry
    func openDetailBlogEntry(_ blogEntry: PostList) {
        let blogEntryCoordinator = BlogEntryCoordinator(self.navigationController, blogEntry: blogEntry)
        childCoordinator.append(blogEntryCoordinator)
        blogEntryCoordinator.start()
    }
}

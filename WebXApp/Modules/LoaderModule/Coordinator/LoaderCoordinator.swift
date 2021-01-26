//
//  LoaderViewCoordinator.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 1/22/21.
//

import UIKit

protocol LoaderCoordinatorProtocol: class {
    init(_ navigationController: UINavigationController)
    func successLoad()
}

class LoaderCoordinator: Coordinator, LoaderCoordinatorProtocol {
    
    var childCoordinator: [Coordinator] = []
    private var navigationController: UINavigationController
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let webasystUserNetworkingService = WebasystUserNetworkingService()
        let loaderViewModel = LoaderViewModel(networkingManager: webasystUserNetworkingService, coordinator: self)
        let loaderViewController = LoaderViewController()
        loaderViewController.viewModel = loaderViewModel
        self.navigationController.setViewControllers([loaderViewController], animated: true)
    }
    
    func successLoad() {
        let tabBarController = UITabBarController()
        // Build Blog View Controller
        let blogNavigationController = UINavigationController()
        blogNavigationController.title = "Блог"
        blogNavigationController.tabBarItem = UITabBarItem(title: "Блог", image: UIImage(systemName: "newspaper"), tag: 0)
        let blogCoordinator = BlogCoordinator(blogNavigationController)
        blogCoordinator.start()
        //Build Site View Controller
        let siteNavigationController = UINavigationController()
        siteNavigationController.title = "Сайт"
        siteNavigationController.tabBarItem = UITabBarItem(title: "Сайт", image: UIImage(systemName: "doc.text"), tag: 1)
        let siteCoordinator = SiteCoordinator(siteNavigationController)
        siteCoordinator.start()
        //Build Shop View Controller
        let shopNavigationController = UINavigationController()
        shopNavigationController.title = "Магазин"
        shopNavigationController.tabBarItem = UITabBarItem(title: "Магазин", image: UIImage(systemName: "cart"), tag: 2)
        let shopCoordinator = ShopCoordinator(shopNavigationController)
        shopCoordinator.start()
        tabBarController.setViewControllers([blogNavigationController, siteNavigationController, shopNavigationController], animated: true)
        UIApplication.shared.windows.filter{$0.isKeyWindow}.first?.rootViewController = tabBarController
    }
    
}
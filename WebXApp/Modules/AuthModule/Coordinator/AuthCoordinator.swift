//
//  AuthWebCoordinator.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 1/13/21.
//

import UIKit

protocol AuthCoordinatorProtocol {
    init(_ navigationController: UINavigationController)
    func successAuth()
    func errorAuth()
}

class AuthCoordinator: Coordinator, AuthCoordinatorProtocol {
    
    private var navigationController: UINavigationController

    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    private(set) var childCoordinator: [Coordinator] = []
    
    func start() {
        let authViewController = AuthViewController()
        let authCoordinator = AuthCoordinator(self.navigationController)
        let networkingService = AuthNetworkingService()
        let authViewModel = AuthViewModel(networkingService: networkingService, coordinator: authCoordinator)
        authViewController.viewModel = authViewModel
        self.navigationController.present(authViewController, animated: true, completion: nil)
    }
    
    func successAuth() {
        self.navigationController.dismiss(animated: true, completion: nil)
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
    
    func errorAuth() {
        self.navigationController.dismiss(animated: true, completion: nil)
        let alertController = UIAlertController(title: "Ошибка", message: "Ошибка авторизации. Попробуйте повторить попытку позже", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ок", style: .cancel, handler: nil))
        self.navigationController.present(alertController, animated: true, completion: nil)
    }
    
}

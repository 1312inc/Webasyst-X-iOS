//
//  Coordinator.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 1/13/21.
//

import UIKit

protocol Coordinator: class {
    var childCoordinator: [Coordinator] { get }
    func start()
}

final class AppCoordinator: Coordinator {
    
    private(set) var childCoordinator: [Coordinator] = []
    
    private var window: UIWindow?
    
    required init(window: UIWindow) {
        self.window = window
    }
    
    func start() {
        if let token = KeychainManager.load(key: "accessToken") {
            debugPrint(String(decoding: token, as: UTF8.self))
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
            guard let window = self.window else { return }
            window.rootViewController = tabBarController
            window.makeKeyAndVisible()
        } else {
            let navigationController = UINavigationController()
            let welcomeCoordinator = WelcomeCoordinator(navigationController)
            childCoordinator.append(welcomeCoordinator)
            welcomeCoordinator.start()
            guard let window = window else { return }
            window.rootViewController = navigationController
            window.makeKeyAndVisible()
        }
        
    }
    
}

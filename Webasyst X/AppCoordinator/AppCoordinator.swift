//
//  Coordinator.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 1/13/21.
//

import UIKit
import Webasyst

protocol Coordinator: AnyObject {
    var childCoordinator: [Coordinator] { get }
    func start()
}

final class AppCoordinator: Coordinator {
    
    private(set) var childCoordinator: [Coordinator] = []
    private let webasyst = WebasystApp()
    private var window: UIWindow?
    
    required init(window: UIWindow) {
        self.window = window
    }
    
    func start() {
        let loadingViewController = LoadingViewController()
        self.window?.rootViewController = loadingViewController
        self.window?.makeKeyAndVisible()
        webasyst.checkUserAuth { userStatus in
            switch userStatus {
            case .authorized:
                DispatchQueue.main.async {
                    let tabBarController = UITabBarController()
                    // Build Blog View Controller
                    let blogNavigationController = UINavigationController()
                    blogNavigationController.tabBarItem = UITabBarItem(title: NSLocalizedString("blogTitle", comment: ""), image: UIImage(systemName: "pencil"), tag: 0)
                    let blogCoordinator = BlogCoordinator(blogNavigationController)
                    blogCoordinator.start()
                    //Build Site View Controller
                    let siteNavigationController = UINavigationController()
                    siteNavigationController.tabBarItem = UITabBarItem(title: NSLocalizedString("siteTitle", comment: ""), image: UIImage(systemName: "doc.text"), tag: 1)
                    let siteCoordinator = SiteCoordinator(siteNavigationController)
                    siteCoordinator.start()
                    //Build Shop View Controller
                    let shopNavigationController = UINavigationController()
                    shopNavigationController.tabBarItem = UITabBarItem(title: NSLocalizedString("shopTitle", comment: ""), image: UIImage(systemName: "cart"), tag: 2)
                    let shopCoordinator = ShopCoordinator(shopNavigationController)
                    shopCoordinator.start()
                    tabBarController.setViewControllers([blogNavigationController, siteNavigationController, shopNavigationController], animated: true)
                    self.window?.rootViewController = tabBarController
                    self.window?.makeKeyAndVisible()
                    return
                }
            case .nonAuthorized:
                DispatchQueue.main.async {
                    let navigationController = UINavigationController()
                    let welcomeCoordinator = WelcomeCoordinator(navigationController)
                    self.childCoordinator.append(welcomeCoordinator)
                    welcomeCoordinator.start()
                    guard let window = self.window else { return }
                    window.rootViewController = navigationController
                    window.makeKeyAndVisible()
                    return
                }
            case .error(message: _):
                DispatchQueue.main.async {
                    self.webasyst.logOutUser { result in
                        if result {
                            let navigationController = UINavigationController()
                            let welcomeCoordinator = WelcomeCoordinator(navigationController)
                            self.childCoordinator.append(welcomeCoordinator)
                            welcomeCoordinator.start()
                            guard let window = self.window else { return }
                            window.rootViewController = navigationController
                            window.makeKeyAndVisible()
                            return
                        }
                    }
                }
            }
        }
        
    }
    
}

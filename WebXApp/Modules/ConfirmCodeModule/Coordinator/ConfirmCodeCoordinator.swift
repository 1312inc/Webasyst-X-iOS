//
//  ConfirmCodeCoordinator.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 10.06.2021.
//

import UIKit

protocol ConfirmCodeCoordinatorProtocol {
    var navigationController: UINavigationController { get }
    init(_ navigationController: UINavigationController, phoneNumber: String)
    func showErrorAlert(with: String)
    func successAuth()
}

final class ConfirmCodeCoordinator: Coordinator, ConfirmCodeCoordinatorProtocol {
    
    var childCoordinator: [Coordinator] = []
    var navigationController: UINavigationController
    var phoneNumber: String
    
    init(_ navigationController: UINavigationController, phoneNumber: String) {
        self.navigationController = navigationController
        self.phoneNumber = phoneNumber
    }
    
    func start() {
        DispatchQueue.main.async {
            let viewController = ConfirmCodeViewController()
            let viewModel = ConfirmCodeViewModel(self, phoneNumber: self.phoneNumber)
            viewController.viewModel = viewModel
            self.navigationController.pushViewController(viewController, animated: true)
        }
    }
    
    func successAuth() {
        DispatchQueue.main.async {
            let window = UIApplication.shared.windows.first ?? UIWindow()
            let tabBarController = UITabBarController()
            // Build Blog View Controller
            let blogNavigationController = UINavigationController()
            blogNavigationController.tabBarItem = UITabBarItem(title: NSLocalizedString("blogTitle", comment: ""), image: UIImage(systemName: "newspaper"), tag: 0)
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
            window.rootViewController = tabBarController
            window.makeKeyAndVisible()
        }
    }
    
    func showErrorAlert(with: String) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: NSLocalizedString("errorTitle", comment: ""), message: with, preferredStyle: .alert)
            let alertAction = UIAlertAction(title: NSLocalizedString("okAlert", comment: ""), style: .cancel)
            alertController.addAction(alertAction)
            self.navigationController.present(alertController, animated: true, completion: nil)
        }
    }
    
    
}

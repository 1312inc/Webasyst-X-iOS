//
//  AuthCoordinator.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 1/13/21.
//

import UIKit
import Webasyst

protocol WelcomeCoordinatorProtocol: AnyObject {
    init(_ navigationController: UINavigationController)
    func showWebAuthModal()
    func showConnectionAlert()
    func openPhoneAuth()
}

final class WelcomeCoordinator: Coordinator, WelcomeCoordinatorProtocol {
    
    private(set) var childCoordinator: [Coordinator] = []
    private var navigationController: UINavigationController
    private let webasyst = WebasystApp()
    
    init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let welcomeViewController = WelcomeViewController()
        let welcomeCoordinator = WelcomeCoordinator(navigationController)
        let welcomeViewModel = WelcomeViewModel(coordinator: welcomeCoordinator)
        welcomeViewController.viewModel = welcomeViewModel
        self.navigationController.setViewControllers([welcomeViewController], animated: true)
    }
    
    func showWebAuthModal() {
        webasyst.oAuthLogin(navigationController: self.navigationController) { result in
            switch result {
            case .success:
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
            case .error(error: let error):
                DispatchQueue.main.async {
                    let alertController = UIAlertController(title: NSLocalizedString("errorTitle", comment: ""), message: error, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Ок", style: .cancel, handler: nil))
                    self.navigationController.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    func openPhoneAuth() {
        let authCoordinator = AuthCoordinator(self.navigationController)
        authCoordinator.start()
    }
    
    func showConnectionAlert() {
        let alertController = UIAlertController(title: NSLocalizedString("errorTitle", comment: ""), message: NSLocalizedString("connectionAlertMessage", comment: ""), preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ок", style: .cancel, handler: nil))
        self.navigationController.present(alertController, animated: true, completion: nil)
    }
    
}

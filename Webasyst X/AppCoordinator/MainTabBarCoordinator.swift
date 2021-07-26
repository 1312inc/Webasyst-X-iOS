//
//  MainTabBarCoordinator.swift
//  Finrux
//
//  Created by Виктор Кобыхно on 14.07.2021.
//

import UIKit
import Webasyst

final class MainTabBarCoordinator: NSObject {
    
    private var presenter: UIWindow
    private var tabBarController: UITabBarController
    private var navigationController: UINavigationController
    private var screens: ScreensBuilder
    private var blogCoordinator: BlogCoordinator?
    private var siteCoordinator: SiteCoordinator?
    private var shopCoordinator: ShopCoordinator?
    private var welcomeCoordinator: WelcomeCoordinator?
    private var source: MainTabBarSource = MainTabBarSource()
    
    init(presenter: UIWindow) {
        self.presenter = presenter
        self.screens = ScreensBuilder()
        self.tabBarController = UITabBarController(nibName: nil, bundle: nil)
        self.navigationController = UINavigationController()
        tabBarController.viewControllers = source.items
        tabBarController.selectedViewController = source[.blog]
        super.init()
        tabBarController.delegate = self
    }
    
    func start() {
        //Сначала загружаем ViewController с загрузкой, что бы не было черного экрана пока чекаем авторизацию юзера
        let loadingViewController = LoadingViewController()
        self.presenter.rootViewController = loadingViewController
        let webasyst = WebasystApp()
        webasyst.checkUserAuth { [weak self] userStatus in
            guard let self = self else { return }
            switch userStatus {
            case .authorized:
                self.showTabBar()
            case .nonAuthorized:
                self.showWelcomeScreen()
            case .error(message: _):
                self.showWelcomeScreen()
            }
        }
    }
    
    func authUser() {
        DispatchQueue.main.async {
            self.presenter.rootViewController = self.tabBarController
            self.showBlogTab()
            self.showSiteTab()
            self.showShopTab()
        }
    }
    
    func logOutUser() {
        self.showWelcomeScreen()
    }
    
}

extension MainTabBarCoordinator: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let index = tabBarController.selectedIndex
        guard index < source.items.count, let item = ViewControllerItem(rawValue: index) else {
            fatalError("Index out of range")
        }
        switch item {
        case .blog:
            showBlogTab()
        case .site:
            showSiteTab()
        case .shop:
            showShopTab()
        }
    }
    
}

//MARK: Private method
extension MainTabBarCoordinator {
    
    private func showTabBar() {
        DispatchQueue.main.async {
            self.presenter.rootViewController = self.tabBarController
            self.showBlogTab()
        }
    }
    
    private func showWelcomeScreen() {
        DispatchQueue.main.async {
            self.presenter.rootViewController = self.navigationController
            self.showWelcomeTab()
        }
    }
    
    private func showBlogTab() {
        blogCoordinator = BlogCoordinator(presenter: source[.blog], screens: self.screens)
        blogCoordinator?.start()
    }
    
    private func showSiteTab() {
        siteCoordinator = SiteCoordinator(presenter: source[.site], screens: self.screens)
        siteCoordinator?.start()
    }
    
    private func showShopTab() {
        shopCoordinator = ShopCoordinator(presenter: source[.shop], screens: self.screens)
        shopCoordinator?.start()
    }
    
    private func showWelcomeTab() {
        welcomeCoordinator = WelcomeCoordinator(presenter: self.navigationController, screens: screens)
        welcomeCoordinator?.start()
    }
    
}



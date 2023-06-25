//
//  MainTabBarCoordinator.swift
//  Finrux
//
//  Created by Виктор Кобыхно on 14.07.2021.
//

import UIKit
import Webasyst

final class MainTabBarCoordinator: PasscodeActionDelegate {
    
    private let webasyst = WebasystApp()
    private let screens = ScreensBuilder()
    
    private let navigationController: UINavigationController
    
    private let tabBarController = UITabBarController(nibName: nil, bundle: nil)
    private var source: MainTabBarSource?
    
    private var blogCoordinator: BlogCoordinator?
    private var siteCoordinator: SiteCoordinator?
    private var shopCoordinator: ShopCoordinator?
    
    private lazy var welcomeCoordinator = WelcomeCoordinator(presenter: navigationController, screens: screens)
    private lazy var redactorCoordinator = RedactorCoordinator(presenter: navigationController, screens: screens)
    
    init(presenter: UIWindow, navigationController: UINavigationController) {
        
        self.navigationController = navigationController
        
        super.init(presenter: presenter)
        self.configurePasscodeActions(passcodeSkiped: { [weak self] in
            guard let self = self else { return }
            self.presenter.rootViewController = LoadingViewController()
            self.showTabBar(false)
        }, passcodeSuccessed: { [weak self] in
            guard let self = self else { return }
            self.defaultAuth(notAuthorized: false, withPasscodeCheck: false)
        })
        
        configure()
    }
    
    fileprivate func configure() {
        presenter.backgroundColor = .reverseLabel
        tabBarController.view.backgroundColor = .reverseLabel
        tabBarController.tabBar.tintColor = .appColor
    }
    
}

// MARK: - Start & Auth coordination

extension MainTabBarCoordinator {
    
    func start() {
        //Сначала загружаем ViewController с загрузкой, что бы не было черного экрана пока чекаем авторизацию юзера
        presenter.rootViewController = LoadingViewController()
        if !UserDefaults.standard.bool(forKey: "appLaunch") { return }
        UserDefaults.standard.set(false, forKey: "appLaunch")
        webasyst.defaultChecking { [weak self] notAuthorized in
            guard let self = self else { return }
            self.defaultAuth(notAuthorized: notAuthorized, withPasscodeCheck: true)
        }
    }
    
    func defaultAuth(notAuthorized: Bool, withPasscodeCheck check: Bool) {
        if notAuthorized {
            showWelcomeScreen()
        } else {
            if check {
                showPasscodeLockView()
            } else {
                presenter.rootViewController = LoadingViewController()
                showTabBar(false)
            }
        }
    }
    
    func authUser(_ userStatus: UserStatus, style: AddCoordinatorType) {
        authorized(userStatus, animationNeeds: true, style: style)
    }
    
    func authorized(_ userStatus: UserStatus, animationNeeds: Bool = false, style: AddCoordinatorType) {
        prepare()
        switch userStatus {
        case .authorized, .authorizedButNoneInstalls:
            showTabBar(animationNeeds)
        case .nonAuthorized:
            showWelcomeScreen()
        case .authorizedButProfileIsEmpty:
            showRedactorScreen(status: .authorizedButProfileIsEmpty, style: style)
        case .authorizedButNoneInstallsAndProfileIsEmpty:
            showRedactorScreen(status: .authorizedButNoneInstallsAndProfileIsEmpty, style: style)
        case .networkError(_),.error(message: _):
            showWelcomeScreen()
        }
    }
    
    func logOutUser(style: AddCoordinatorType, needToRepresent: Bool) {
        navigationController.clearAppearance()
        NotificationCenter.default.removeObserver(self)
        if needToRepresent {
            showWelcomeScreen(style: style)
        }
        clearControllers()
        UserDefaults.standard.set(true, forKey: "firstLaunch")
        UserDefaults.setCurrentInstall(withValue: nil)
        AnalyticsManager.logEvent("logout", parameters: nil)
    }
}

// MARK: - Start

extension MainTabBarCoordinator {
 
    private func showTabBar(_ animationNeeds: Bool = false) {

        DispatchQueue.main.async {
            
            self.prepare()
            self.startControllers()
            
            if animationNeeds {
                self.tabBarController.showViewControllerWith(setRoot: self.presenter,
                                                             currentRoot: self.navigationController)
            } else {
                self.presenter.rootViewController = self.tabBarController
            }
        }
        
        AnalyticsManager.setupAuthorizedKeys()
    }
    
    private func showWelcomeScreen(style: AddCoordinatorType = .start) {
        DispatchQueue.main.async {
            let screen = self.screens.createWelcomeViewController(coordinator: self.welcomeCoordinator)
            if style == .indirect {
                self.navigationController.setViewControllers([screen], animated: true)
                self.navigationController.dissolveViewControllerWith(setRoot: self.presenter, currentRoot: self.tabBarController)
            } else {
                self.navigationController.pushViewController(screen, animated: true)
                self.navigationController.setViewControllers([screen], animated: false)
                self.presenter.rootViewController = self.navigationController
            }
            self.welcomeCoordinator.start()
        }
        AnalyticsManager.setupAuthorizedKeys(deleteAll: true)
    }
    
    private func showRedactorScreen(status: UserStatus, style: AddCoordinatorType = .indirect) {
        DispatchQueue.main.async {
            if style == .start {
                self.navigationController.dismiss(animated: true, completion: {
                    self.presenter.rootViewController = self.navigationController
                })
            }
            self.redactorCoordinator.start()
            switch status {
            case .authorizedButProfileIsEmpty, .authorizedButNoneInstallsAndProfileIsEmpty:
                self.redactorCoordinator.completion = {
                    self.showTabBar(true)
                }
            case .nonAuthorized, .error, .authorized, .authorizedButNoneInstalls:
                break
            case .networkError(_):
                break
            }
        }
    }
    
    func pushForDemo() {
        DispatchQueue.main.async {
            self.prepare()
            self.startControllers()
            self.tabBarController.tabBar.isHidden = false
            self.tabBarController.showViewControllerWith(setRoot: self.presenter, currentRoot: self.navigationController)
        }
    }
    
    func goBackToAuth() {
        DispatchQueue.main.async {
            self.navigationController.hideViewControllerWith(setRoot: self.presenter, currentRoot: self.tabBarController)
            self.clearControllers()
        }
    }
    
    private func startControllers() {
        blogCoordinator?.start()
        siteCoordinator?.start()
        shopCoordinator?.start()
    }
    
    private func clearControllers() {
        self.tabBarController.viewControllers?.forEach({
            ($0 as? UINavigationController)?.viewControllers.forEach({
                $0.dismiss(animated: false)
                $0.removeFromParent()
            })
            $0.dismiss(animated: false)
            $0.removeFromParent()
        })
        self.blogCoordinator = nil
        self.siteCoordinator = nil
        self.shopCoordinator = nil
    }
}

// MARK: - Preparing

extension MainTabBarCoordinator {
    
    fileprivate func prepare() {
                
        tabBarController.setViewControllers([], animated: false)
        
        source = MainTabBarSource(controllers: [UINavigationController(), UINavigationController(), UINavigationController()])
        configureCoordinators()
        
        guard let source = source else { return }
        
        tabBarController.setViewControllers(source.items, animated: true)
        tabBarController.selectedViewController = source[.blog]
        
        self.source?.items.removeAll()
        self.source = nil
        
    }
    
    fileprivate func configureCoordinators() {
        guard let source = source else { return }
        blogCoordinator = BlogCoordinator(presenter: source[.contacts], screens: screens)
        siteCoordinator = SiteCoordinator(presenter: source[.transactions], screens: screens)
        shopCoordinator = shopCoordinator(presenter: source[.reminders], screens: screens)
    }
    
}


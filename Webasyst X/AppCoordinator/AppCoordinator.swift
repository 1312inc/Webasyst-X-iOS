//
//  AppCoordinator.swift
//  Finrux
//
//  Created by Виктор Кобыхно on 14.07.2021.
//

import Foundation

final class AppCoordinator {
    
    static let shared = AppCoordinator()
    private init() {}
    
    private var navigationController: UINavigationController!
    unowned var sceneDelegate: SceneDelegate!
    
    var tabBarCoordinator: MainTabBarCoordinator!
    
    func configure(sceneDelegate: SceneDelegate, navigationController: UINavigationController) {
        self.sceneDelegate = sceneDelegate
        self.navigationController = navigationController
        self.tabBarCoordinator = MainTabBarCoordinator(presenter: sceneDelegate.window!, navigationController: navigationController)
    }
    
    func start() {
        tabBarCoordinator.start()
    }
    
    func authUser(_ userStatus: UserStatus, style: AddCoordinatorType) {
        tabBarCoordinator.authUser(userStatus, style: style)
    }
    
    func logOutUser(style: AddCoordinatorType, needToRepresent: Bool = true) {
        tabBarCoordinator.logOutUser(style: style, needToRepresent: needToRepresent)
    }
    
    func pushForDemo() {
        tabBarCoordinator.pushForDemo()
    }
    
    func passcodeLock() {
        tabBarCoordinator.showPasscodeLockView()
    }
}

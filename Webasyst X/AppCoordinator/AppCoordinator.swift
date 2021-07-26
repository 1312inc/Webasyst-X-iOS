//
//  AppCoordinator.swift
//  Finrux
//
//  Created by Виктор Кобыхно on 14.07.2021.
//

import Foundation

final class AppCoordinator {
    
    private unowned var sceneDelegate: SceneDelegate
    
    private var tabBarCoordinator: MainTabBarCoordinator?
    
    init(sceneDelegate: SceneDelegate) {
        self.sceneDelegate = sceneDelegate
    }
    
    func start() {
        tabBarCoordinator = MainTabBarCoordinator(presenter: sceneDelegate.window!)
        tabBarCoordinator?.start()
    }
    
    func authUser() {
        tabBarCoordinator = MainTabBarCoordinator(presenter: sceneDelegate.window!)
        tabBarCoordinator?.authUser()
    }
    
    func logOutUser() {
        tabBarCoordinator = MainTabBarCoordinator(presenter: sceneDelegate.window!)
        tabBarCoordinator?.logOutUser()
    }
    
}

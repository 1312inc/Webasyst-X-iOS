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
        let navigationController = UINavigationController()
        let authCoordinator = WelcomeCoordinator(navigationController)
        childCoordinator.append(authCoordinator)
        authCoordinator.start()
        guard let window = window else { return }
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
    
}

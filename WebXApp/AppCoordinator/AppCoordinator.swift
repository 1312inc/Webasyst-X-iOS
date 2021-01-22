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
            let navigationController = UINavigationController()
            let loaderCoordinator = LoaderCoordinator(navigationController)
            childCoordinator.append(loaderCoordinator)
            loaderCoordinator.start()
            guard let window = window else { return }
            window.rootViewController = navigationController
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

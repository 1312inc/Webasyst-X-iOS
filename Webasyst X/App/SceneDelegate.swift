//
//  SceneDelegate.swift
//  WebXApp
//
//  Created by Administrator on 10.11.2020.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var navigationController = UINavigationController()
    let coordinator = AppCoordinator.shared
    
    var webasystSceneManager: WebasystSceneManager!

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        webasystSceneManager = WebasystSceneManager(activatePasscodeLock: { [weak self] in
            self?.coordinator.passcodeLock()
        })
        window = UIWindow(windowScene: scene)
        window!.makeKeyAndVisible()
        coordinator.configure(sceneDelegate: self, navigationController: navigationController)
        coordinator.start()
    }
}


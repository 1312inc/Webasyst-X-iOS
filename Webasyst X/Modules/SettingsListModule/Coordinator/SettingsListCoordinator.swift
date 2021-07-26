//
//  SettingsList module - SettingsListCoordinator.swift
//  Teamwork
//
//  Created by viktkobst on 21/07/2021.
//  Copyright © 2021 1312 Inc.. All rights reserved.
//

import UIKit
import Webasyst

//MARK SettingsListCoordinator
final class SettingsListCoordinator {
    
    var presenter: UINavigationController
    var screens: ScreensBuilder
    var settingsListNavigationControler: UINavigationController?
    
    init(presenter: UINavigationController, screens: ScreensBuilder) {
        self.presenter = presenter
        self.screens = screens
    }
    
    func start() {
        self.initialViewController()
    }
    
    //MARK: Initial ViewController
    private func initialViewController() {
        let viewController = screens.createSettingsListViewController(coordinator: self)
        settingsListNavigationControler = UINavigationController(rootViewController: viewController)
        if let navigation = self.settingsListNavigationControler {
            presenter.present(navigation, animated: true, completion: nil)
        }
    }
    
    func openAddNewAccount() {
        guard let presenter = self.settingsListNavigationControler else { return }
        let coordinator = AddAccoutCoordinator(presenter: presenter, screens: self.screens)
        coordinator.start()
    }
    
    func logoutUser() {
        let scene = UIApplication.shared.connectedScenes.first
        guard let sceneDelegate = scene?.delegate as? SceneDelegate else { return }
        let appCoordinator = AppCoordinator(sceneDelegate: sceneDelegate)
        appCoordinator.logOutUser()
    }
    
    func dissmisViewController() {
        self.presenter.dismiss(animated: true, completion: nil)
    }
    
}

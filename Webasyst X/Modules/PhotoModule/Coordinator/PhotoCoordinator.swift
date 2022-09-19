//
//  PhotoCoordinator.swift
//  Webasyst X
//
//  Created by Леонид Лукашевич on 18.09.2022.
//

import UIKit

final class PhotoCoordinator {
    
    var presenter: UINavigationController
    var screens: ScreensBuilder

    init(presenter: UINavigationController, screens: ScreensBuilder) {
        self.presenter = presenter
        self.screens = screens
    }
    
    func start() {
        self.initialViewController()
    }
    
    //MARK: Initial ViewController
    private func initialViewController() {
        let viewController = screens.createPhotoViewController(coordinator: self)
        presenter.viewControllers = [viewController]
    }
    
    func openSettingsList() {
        let settingsListCoordinator = SettingsListCoordinator(presenter: self.presenter, screens: self.screens)
        settingsListCoordinator.start()
    }
}

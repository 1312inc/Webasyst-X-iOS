//
//  Site module - SiteCoordinator.swift
//  Webasyst-X-iOS
//
//  Created by viktkobst on 26/07/2021.
//  Copyright © 2021 1312 Inc.. All rights reserved.
//

import UIKit

//MARK SiteCoordinator
final class SiteCoordinator {
    
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
        let viewController = screens.createSiteViewController(coordinator: self)
        presenter.viewControllers = [viewController]
    }
    
    func openDetailSiteScreen(page: String) {
        let siteDetailCoordinator = SiteDetailCoordinator(presenter: self.presenter, screens: self.screens)
        siteDetailCoordinator.start(page: page)
    }
    
    func openSettingsList() {
        let settingsListCoordinator = SettingsListCoordinator(presenter: self.presenter, screens: self.screens)
        settingsListCoordinator.start()
    }
    
}

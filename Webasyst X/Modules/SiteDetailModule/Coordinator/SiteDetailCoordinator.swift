//
//  SiteDetail module - SiteDetailCoordinator.swift
//  Webasyst-X-iOS
//
//  Created by viktkobst on 26/07/2021.
//  Copyright © 2021 1312 Inc.. All rights reserved.
//

import UIKit

//MARK SiteDetailCoordinator
final class SiteDetailCoordinator {
    
    var presenter: UINavigationController
    var screens: ScreensBuilder
    
    init(presenter: UINavigationController, screens: ScreensBuilder) {
        self.presenter = presenter
        self.screens = screens
    }
    
    func start(page: String) {
        self.initialViewController(page: page)
    }
    
    //MARK: Initial ViewController
    private func initialViewController(page: String) {
        let viewController = screens.createSiteDetailViewController(coordinator: self, page: page)
        presenter.pushViewController(viewController, animated: true)
    }
    
}

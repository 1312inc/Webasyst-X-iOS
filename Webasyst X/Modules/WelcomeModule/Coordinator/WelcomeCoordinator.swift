//
//  Welcome module - WelcomeCoordinator.swift
//  Teamwork
//
//  Created by viktkobst on 19/07/2021.
//  Copyright © 2021 1312 Inc.. All rights reserved.
//

import UIKit
import Webasyst

//MARK WelcomeCoordinator
final class WelcomeCoordinator {
    
    unowned var presenter: UINavigationController
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
        let viewController = screens.createWelcomeViewComtroller(coordinator: self)
        presenter.viewControllers = [viewController]
    }
    
    func openAuthController() {
        let authCoordinator = AuthCoordinator(presenter: presenter, screens: screens, type: .normal)
        authCoordinator.start()
    }
    
}

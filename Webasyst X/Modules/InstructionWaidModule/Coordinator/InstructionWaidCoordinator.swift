//
//  InstructionWaid module - InstructionWaidCoordinator.swift
//  Teamwork
//
//  Created by viktkobst on 22/07/2021.
//  Copyright © 2021 1312 Inc.. All rights reserved.
//

import UIKit

//MARK InstructionWaidCoordinator
final class InstructionWaidCoordinator {
    
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
        let viewController = screens.createInstructionWaidViewController(coordinator: self)
        presenter.pushViewController(viewController, animated: true)
    }
    
}

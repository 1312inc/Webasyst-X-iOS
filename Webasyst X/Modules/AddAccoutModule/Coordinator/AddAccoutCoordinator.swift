//
//  AddAccout module - AddAccoutCoordinator.swift
//  Teamwork
//
//  Created by viktkobst on 22/07/2021.
//  Copyright © 2021 1312 Inc.. All rights reserved.
//

import UIKit

//MARK AddAccoutCoordinator
final class AddAccoutCoordinator {
    
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
        let viewController = screens.createAddAccountViewController(coordinator: self)
        presenter.pushViewController(viewController, animated: true)
    }
    
    func openInstructionWaid() {
        let coordinator = InstructionWaidCoordinator(presenter: self.presenter, screens: self.screens)
        coordinator.start()
    }
    
    func showAlert(title: String, message: String) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.presenter.present(alertController, animated: true, completion: nil)
        }
    }
    
}

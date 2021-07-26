//
//  ConfirmPhone module - ConfirmPhoneCoordinator.swift
//  Teamwork
//
//  Created by viktkobst on 21/07/2021.
//  Copyright © 2021 1312 Inc.. All rights reserved.
//

import UIKit

//MARK ConfirmPhoneCoordinator
final class ConfirmPhoneCoordinator {
    
    var presenter: UINavigationController
    var screens: ScreensBuilder
    var phoneNumber: String
    
    init(presenter: UINavigationController, screens: ScreensBuilder, phoneNumber: String) {
        self.presenter = presenter
        self.screens = screens
        self.phoneNumber = phoneNumber
    }
    
    func start() {
        self.initialViewController()
    }
    
    //MARK: Initial ViewController
    private func initialViewController() {
        let viewController = screens.createConfirmPhoneViewController(coordinator: self, phoneNumber: self.phoneNumber)
        presenter.pushViewController(viewController, animated: true)
    }
    
    func successAuth() {
        DispatchQueue.main.async {
            let scene = UIApplication.shared.connectedScenes.first
            if let sceneDelegate = scene?.delegate as? SceneDelegate {
                let appCoordinator = AppCoordinator(sceneDelegate: sceneDelegate)
                appCoordinator.authUser()
            }
        }
    }
    
    func showErrorAlert(with: String) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: NSLocalizedString("errorTitle", comment: ""), message: with, preferredStyle: .alert)
            let alertAction = UIAlertAction(title: NSLocalizedString("okAlert", comment: ""), style: .cancel)
            alertController.addAction(alertAction)
            self.presenter.present(alertController, animated: true, completion: nil)
        }
    }
    
}

//
//  PhoneAuth module - PhoneAuthCoordinator.swift
//  Teamwork
//
//  Created by viktkobst on 20/07/2021.
//  Copyright © 2021 1312 Inc.. All rights reserved.
//

import UIKit

//MARK PhoneAuthCoordinator
final class PhoneAuthCoordinator {
    
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
        let viewController = screens.createPhoneAuthViewComtroller(coordinator: self)
        presenter.pushViewController(viewController, animated: true)
    }
    
    func openConfirmPhoneScreen(phoneNumber: String) {
        let confirmPhoneCoordinator = ConfirmPhoneCoordinator(presenter: self.presenter, screens: self.screens, phoneNumber: phoneNumber)
        confirmPhoneCoordinator.start()
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

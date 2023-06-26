//
//  AddAccountCoordinator.swift
//  Shop-Script
//
//  Created by Леонид Лукашевич on 02.10.2022.
//

import UIKit
import Webasyst

@objc enum AddCoordinatorType: Int {
    case start
    case indirect
}

//MARK AddAccoutCoordinator
final class AddAccountCoordinator: WebasystScreenNavigation, WebasystNavigationType {
    
    var presenter: UINavigationController
    var screens: WebasystScreensBuilder
    var type: AddCoordinatorType
    var closure: (() -> ())? = nil
    
    init(presenter: UINavigationController, screens: WebasystScreensBuilder, type: AddCoordinatorType) {
        
        self.presenter = presenter
        self.screens = screens
        self.type = type
        
        super.init()
        
        self.configure(delegate: self)
    }
    
    func start() {
        initialViewController()
    }
    
    private func initialViewController() {
        let viewController = screens.createAddAccountViewController(coordinator: self)
        presenter.appearanceColor(color: .reverseLabel)
        presenter.pushViewController(viewController, animated: true)
        installNewAccount(viewController: viewController, completion: self.closure)
    }
    
    private func installNewAccount(viewController: AddAccountViewController, completion: (() -> ())?) {
        viewController.completion = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if case .start = self.type {
                    self.presenter.popToRootViewController(animated: false)
                } else {
                    self.presenter.dismiss(animated: true)
                }
                
                self.reloadViewControllers()
                if let completion = completion {
                    completion()
                }
            }
        }
    }
    
}

extension AddAccountCoordinator {
    
    func openQRController(withResult result: @escaping (String) -> ()) {
        let coord = QRCoordinator(presenter: presenter, screens: screens) { code in
            result(code)
        }
        coord.start(.link)
    }
    
    func showAlert(title: String, message: String) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.presenter.present(alertController, animated: true, completion: nil)
        }
    }
    
}

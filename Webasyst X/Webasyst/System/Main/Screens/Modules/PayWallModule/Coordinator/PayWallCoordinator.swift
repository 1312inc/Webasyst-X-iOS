//
//  PayWallCoordinator.swift
//  Shop-Script
//
//  Created by Леонид Лукашевич on 19.12.2022.
//

import UIKit

//MARK PayWallCoordinator
final class PayWallCoordinator {
    
    var presenter: UINavigationController
    var screens: ScreensBuilder
    
    init(presenter: UINavigationController, screens: ScreensBuilder) {
        self.presenter = presenter
        self.screens = screens
    }
    
    func start(delegate: StoreKitPaywallSuccessful) {
        self.initialViewController(delegate: delegate)
    }
    
    //MARK: Initial ViewController
    private func initialViewController(delegate: StoreKitPaywallSuccessful) {
        let viewController = screens.createPayWallViewController(delegate: delegate,
                                                                 coordinator: self)
        presenter.pushViewController(viewController, animated: true)
    }
    
    func showAlert(error: Error?) {
        DispatchQueue.main.async {
            let localized = NSLocalizedString("restorePurchases", comment: "")
            let alertController = UIAlertController(title: localized,
                                                    message: error?.localizedDescription, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { _ in
                self.presenter.popViewController(animated: true)
            }))
            self.presenter.present(alertController, animated: true, completion: nil)
        }
    }
    
}

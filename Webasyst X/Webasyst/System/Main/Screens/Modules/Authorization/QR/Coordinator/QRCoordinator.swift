//
//  QRCoordinator.swift
//  Shop-Script
//
//  Created by Леонид Лукашевич on 18.01.2023.
//

import UIKit

final class QRCoordinator: WebasystScreenNavigation, WebasystNavigationType {
    
    enum QRType {
        case auth
        case link
    }
    
    var presenter: UINavigationController
    var screens: WebasystScreensBuilder
    var completion: ((_ code: String) -> ())?
    
    init(presenter: UINavigationController, screens: WebasystScreensBuilder, completion: ((_ code: String) -> ())? = nil) {
        
        self.presenter = presenter
        self.screens = screens
        self.completion = completion
        
        super.init()
        
        self.configure(delegate: self)
    }
    
    func start(_ type: QRType) {
        self.initialViewController(type)
    }
    
    private func initialViewController(_ type: QRType) {
        let viewController = screens.createQRViewController(coordinator: self, type: type)
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .pageSheet
        presenter.present(navigationController, animated: true)
    }
    
    func showErrorAlert(with: String, presenter: QRViewController) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: .getLocalizedString(withKey: "errorTitle"), message: with, preferredStyle: .alert)
            let alertAction = UIAlertAction(title: .getLocalizedString(withKey: "okAlert"), style: .cancel) { _ in 
                presenter.reloadSesson()
            }
            alertController.addAction(alertAction)
            presenter.present(alertController, animated: true, completion: nil)
        }
    }
}

extension QRCoordinator {
    
    func openExpressAuthScreen(_ viewController: QRViewController, domain: String?, code: String) {
        let coordinator = AuthCoordinator(presenter: viewController.navigationController!, screens: screens, type: .express(domain: domain, code: code))
        coordinator.start()
    }
    
    func successAuth() {
        self.webasyst.checkUserAuth { [weak self] userStatus in
            DispatchQueue.main.async {
                self?.authorize(with: userStatus)
            }
        }
    }
}

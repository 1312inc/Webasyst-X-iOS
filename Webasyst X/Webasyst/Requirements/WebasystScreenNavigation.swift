//
//  Navigation.swift
//  Shop-Script
//
//  Created by Леонид Лукашевич on 06.04.2023.
//

import UIKit
import Webasyst

protocol WebasystNavigationType: WebasystScreenNavigation {
    var presenter: UINavigationController { get }
}

class WebasystScreenNavigation: CurrentUser {
    
    private unowned var parent: WebasystNavigationType!
    private let appCoordinator = AppCoordinator.shared
    
    func configure(delegate: WebasystNavigationType) {
        self.parent = delegate
    }
    
    // MARK: - Account actions
    
    func authorize(with userStatus: UserStatus, closure: () -> () = {}) {
        Service.Demo.isDemo = false
        closure()
        appCoordinator.authUser(userStatus, style: .start)
    }
    
    func openDemo() {
        Service.Demo.isDemo = true
        UserDefaults.setCurrentInstall(withValue: Service.Demo.demoToken)
        appCoordinator.pushForDemo()
    }
    
    func logout(_ closure: () -> () = {}) {
        appCoordinator.logOutUser(style: .indirect, needToRepresent: false)
        closure()
    }
    
    // MARK: - Alert
    
    func showErrorAlert(with: String) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: .getLocalizedString(withKey: "errorTitle"), message: with, preferredStyle: .alert)
            let alertAction = UIAlertAction(title: .getLocalizedString(withKey: "okAlert"), style: .cancel)
            alertController.addAction(alertAction)
            self.parent.presenter.present(alertController, animated: true, completion: nil)
        }
    }
    
    // MARK: - Profile
    
    func resetViewControllers(withLoading: Bool = false) {
        
    }
    
    func reloadViewControllers() {
        (parent.presenter.topViewController as? BaseViewController)?.reloadViewControllers()
        parent.presenter.tabBarController?.tabBar.isHidden = false
    }
    
}

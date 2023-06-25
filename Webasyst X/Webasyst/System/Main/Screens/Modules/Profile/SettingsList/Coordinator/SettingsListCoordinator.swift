//
//  SettingsListCoordinator.swift
//  Shop-Script
//
//  Created by Леонид Лукашевич on 05.10.2022.
//

import UIKit
import Webasyst
import RxCocoa

//MARK SettingsListCoordinator
final class SettingsListCoordinator: WebasystScreenNavigation, WebasystNavigationType {
    
    var presenter: UINavigationController
    var screens: WebasystScreensBuilder
    var closure: () -> ()
    
    var settingsListNavigationControler: UINavigationController? {
        return presenter.presentedViewController as? UINavigationController
    }
    
    init(presenter: UINavigationController, screens: WebasystScreensBuilder, block: @escaping () -> ()) {
        
        self.presenter = presenter
        self.screens = screens
        self.closure = block
        
        super.init()
        
        self.configure(delegate: self)
    }
    
    func start() {
        self.initialViewController()
    }
    
    private func initialViewController() {
        let viewController = screens.createSettingsListViewController(coordinator: self)
        viewController.navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: .getLocalizedString(withKey: "exitAccountButtonTitle"),
            style: .done,
            target: self,
            action: #selector(logout)
        )
        let settingsListNavigationControler = UINavigationController(rootViewController: viewController)
        presenter.present(settingsListNavigationControler, animated: true, completion: nil)
    }
    
}

extension SettingsListCoordinator {
    
    func openRedactorViewController(image: UIImage?, profile: ProfileData, delegate: PassImageToPreviousController) {
        if let settingsListNavigationControler = settingsListNavigationControler {
            let coordinator = RedactorCoordinator(presenter: settingsListNavigationControler, screens: screens)
            coordinator.startFromSelector(image: image, profile: profile, delegate: delegate)
        }
    }
    
    func openAddNewAccount() {
        if let navigation = self.settingsListNavigationControler {
            let coordinator = AddAccountCoordinator(presenter: navigation, screens: screens, type: .indirect)
            coordinator.closure = { [weak self] in
                self?.resetViewControllers(withLoading: true)
                self?.reloadViewControllers()
            }
            coordinator.start()
        }
    }
    
    @objc func logout() {
        if let navigation = settingsListNavigationControler {
            CustomTimer.shared.stopTimer()
            webasyst.getAllUserInstall { [weak self] installs in
                if let installs = installs {
                    for install in installs {
                        PushNotificationNetworkManger.shared.changeStatus(to: false, install.accessToken)
                    }
                }
                self?.signOut(with: false, navigationController: navigation, style: .indirect)
            }
        }
    }
    
    func dissmisViewController(dismiss: Bool = true) {
        
        resetViewControllers()
        
        CustomTimer.shared.stopTimer()
        if dismiss {
            self.presenter.dismiss(animated: true, completion: closure)
        } else {
            closure()
        }
    }
    
}

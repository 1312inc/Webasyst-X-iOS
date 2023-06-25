//
//  BaseViewController.swift
//  Webasyst X
//
//  Created by Леонид Лукашевич on 25.06.2023.
//

import UIKit

class BaseViewController: UIViewController {
    
    func reloadViewControllers() {
        AppCoordinator.shared.tabBarCoordinator.showTabBar(false)
    }
}

extension BaseViewController: InstallDelegate {
    
    func installModuleTap() {
        let alertController = UIAlertController(title: "Install module", message: "Tap in install module button", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alertController.addAction(action)
        self.navigationController?.present(alertController, animated: true, completion: nil)
    }
}

extension BaseViewController: AddAccountDelegate {
    
    func linkAccountWithQR() {
        
    }
    
    func linkAccount() {
        
    }
    
    func connectAccount(withDigitalCode: String, completion: @escaping (Bool) -> ()) {
        
    }
    
    func addAccount(shopDomain: String?, shopName: String?, startLoading: @escaping () -> (), stopLoading: @escaping () -> (), completion: @escaping (Bool) -> ()) {
        
    }
}

//
//  CurrentUser.swift
//  Shop-Script
//
//  Created by Леонид Лукашевич on 05.10.2022.
//

import UIKit
import Webasyst

class StorageCleaner: Codable {}

class CurrentUser {
    
    lazy var webasyst = WebasystApp()
    
    @objc func signOut(with merge: Bool, navigationController: UINavigationController, style: AddCoordinatorType) {
        DispatchQueue.main.async {
            if merge {
                AppCoordinator.shared.logOutUser(style: style)
            } else {
                self.webasyst.logOutUser { [weak self] _ in
                    guard let self = self else { return }
                    let url = WebasystApp.url()
                    do {
                        try FileManager.default.removeItem(at: url)
                    } catch {
                        print(error, "debugRemove")
                    }
                    AppCoordinator.shared.logOutUser(style: style)
                }
            }
        }
    }
}


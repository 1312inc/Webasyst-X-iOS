//
//  ConfirmPhoneCoordinator.swift
//  Shop-Script
//
//  Created by Леонид Лукашевич on 03.10.2022.
//

import UIKit
import Webasyst

final class ConfirmPhoneCoordinator: WebasystScreenNavigation, WebasystNavigationType {
    
    var presenter: UINavigationController
    var screens: WebasystScreensBuilder
    var type: AuthCoordinator.AuthType
    
    var phoneNumber: String
    
    init(presenter: UINavigationController, screens: WebasystScreensBuilder, phoneNumber: String, type: AuthCoordinator.AuthType) {
        
        self.presenter = presenter
        self.screens = screens
        self.phoneNumber = phoneNumber
        self.type = type
        
        super.init()
        
        configure(delegate: self)
    }
    
    func start() {
        self.initialViewController()
    }
    
    private func initialViewController() {
        let viewController = screens.createConfirmPhoneViewController(coordinator: self, phoneNumber: self.phoneNumber)
        presenter.pushViewController(viewController, animated: true)
    }
    
}

extension ConfirmPhoneCoordinator {
    
    func successAuth(_ completion: @escaping () -> ()) {
        
        let successAuthClosure: (UserStatus) -> () = { [weak self] userStatus in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.authorize(with: userStatus)
            }
        }
        
        switch type {
        case .normal:
            self.webasyst.checkUserAuth { status in
                successAuthClosure(status)
            }
        case .express(_, let code):
            
            var currentStatus: UserStatus!
                
            let successAuthGroup = DispatchGroup()
            
            successAuthGroup.enter()
            self.webasyst.checkUserAuth { status in
                completion()
                currentStatus = status
                successAuthGroup.leave()
            }
            
            successAuthGroup.enter()
            AddAccountNetworking.shared.connectWebasystAccount(withDigitalCode: code) { [weak self] success, id, url in
                if success {
                    successAuthGroup.leave()
                } else {
                    DispatchQueue.main.async {
                        guard let self = self else { return }
                        self.presenter.topViewController?.showAlert(withTitle: .getLocalizedString(withKey: "qrConnectWebasystAccountError"), errorMessage: url, analytics: AnalyticsModel(type: "waid", debugInfo: debug(), method: "connectWebasystAccount")) {
                            successAuthGroup.leave()
                        }
                    }
                }
            }
            
            successAuthGroup.notify(queue: .main) {
                successAuthClosure(currentStatus)
            }
        }
    }
}

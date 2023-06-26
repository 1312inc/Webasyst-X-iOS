//
//  AuthCoordinator.swift
//  Shop-Script
//
//  Created by Леонид Лукашевич on 03.10.2022.
//

import UIKit
import Webasyst

final class AuthCoordinator: WebasystScreenNavigation, WebasystNavigationType {
    
    enum AuthType {
        case normal
        case express(domain: String?, code: String)
    }
        
    var presenter: UINavigationController
    var screens: WebasystScreensBuilder
    var type: AuthType
    
    var authController: AuthorizationAppleIDController?
    
    init(presenter: UINavigationController, screens: WebasystScreensBuilder, type: AuthType) {
        
        self.presenter = presenter
        self.screens = screens
        self.type = type
        
        super.init()
        
        configure(delegate: self)
    }
    
    func start() {
        self.initialViewController()
    }
    
    private func initialViewController() {
        let viewController = screens.createAuthViewController(coordinator: self)
        presenter.pushViewController(viewController, animated: true)
    }
    
}

// MARK: - Actions

extension AuthCoordinator {
    
    func openDemoViewController() {
        DispatchQueue.main.async {
            self.openDemo()
        }
    }
    
    func QRLogin() {
        let coord = QRCoordinator(presenter: presenter, screens: screens)
        coord.start(.auth)
    }
    
    func openPhoneLogin(_ viewController: AuthViewController, phone: String) {
        let coord = ConfirmPhoneCoordinator(presenter: presenter, screens: screens, phoneNumber: phone, type: type)
        coord.start()
    }
    
    func webasystIDLogin() {
        webasyst.oAuthLogin(navigationController: self.presenter) { [weak self] userStatus in
            DispatchQueue.main.async {
                self?.authorize(with: userStatus) { [weak self] in
                    self?.presenter.dismiss(animated: true)
                }
            }
        }
    }
    
    func appleIDLogin(vc: AuthViewController) {
        
        authController = AuthorizationAppleIDController(viewController: vc) { [weak self] authData in
            
            DispatchQueue.main.async {
                vc.view().startLoading()
            }

            self?.webasyst.oAuthAppleID(authData: authData) { [weak self] result in

                switch result {
                case .needEmailConfirmation(let email, let confirmHandler):

                    DispatchQueue.main.async {
                        let emailConfirmationVC = EmailConfirmationAppleIDViewController(email: email) { result, delegate in
                            
                            let successHandler: (Bool, String?) -> () = { [weak self] success, errorDescription in

                                if success {
                                    
                                    switch result {
                                    case .code:
                                        self?.webasyst.checkUserAuth { [weak self] userStatus in
                                            DispatchQueue.main.async {
                                                self?.authorize(with: userStatus)
                                            }
                                        }
                                    case .logout:
                                        DispatchQueue.main.async {
                                            self?.logout() { [weak self] in
                                                self?.presenter.presentedViewController?.dismiss(animated: true)
                                            }
                                        }
                                    }

                                } else {
                                    DispatchQueue.main.async {
                                        let title: String = .getLocalizedString(withKey: "errorTitle")
                                        let description: String = .getLocalizedString(withKey: "failedAppleIDMerge")
                                        if let errorDescription = errorDescription {
                                            delegate.alertPresenter.showAlert(withTitle: title, description: description, errorMessage: errorDescription, analytics: AnalyticsModel(type: "waid", debugInfo: debug(), method: "oAuthAppleID"))
                                        } else {
                                            delegate.alertPresenter.showAlert(withTitle: title, description: description, analytics: AnalyticsModel(type: "waid", debugInfo: debug(), method: "oAuthAppleID"))
                                        }
                                        delegate.stopLoading()
                                    }
                                }
                            }
                            
                            confirmHandler(AuthAppleIDResult.EmailConfirmation(result, successHandler))
                        }
                        
                        let nc = UINavigationController(rootViewController: emailConfirmationVC)
                        nc.modalTransitionStyle = .crossDissolve
                        nc.modalPresentationStyle = .overFullScreen
                        self?.presenter.present(nc, animated: true) {
                            vc.view().stopLoading()
                        }
                    }

                case .completed(let userStatus):

                    switch userStatus {
                    case .error(let message):

                        DispatchQueue.main.async {
                            vc.view().stopLoading()
                            self?.presenter.showAlert(withTitle: .getLocalizedString(withKey: "errorTitle"),
                                                     description: .getLocalizedString(withKey: "failedAppleIDAuth"),
                                                     errorMessage: .getLocalizedString(withKey: "serverSentError") + message,
                                                     analytics: AnalyticsModel(type: "login", debugInfo: debug(), method: "oAuthAppleID"))
                        }

                    default:

                        self?.webasyst.checkUserAuth { [weak self] userStatus in
                            DispatchQueue.main.async {
                                self?.authorize(with: userStatus)
                            }
                        }
                    }
                }
            }
        }
        authController?.authorize()
    }
    
}

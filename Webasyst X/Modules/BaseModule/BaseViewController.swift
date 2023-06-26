//
//  BaseViewController.swift
//  Webasyst X
//
//  Created by Леонид Лукашевич on 25.06.2023.
//

import UIKit
import Webasyst

class BaseViewController: UIViewController {
    
    weak var baseCoordinator: BaseCoordinator?
    
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    public let webasyst = WebasystApp()
    
    init(baseCoordinator: BaseCoordinator) {
        self.baseCoordinator = baseCoordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reloadViewControllers() {
        AppCoordinator.shared.tabBarCoordinator.showTabBar(false)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    @objc public
    func openSettingsList() {
        guard let projectCoordinator = baseCoordinator else { return }
        projectCoordinator.openSettingsList(closure: { [weak self] in
            guard let self = self else { return }
            reloadViewControllers()
        })
    }
    
    @objc
    func logOut() {
        let currentUser = CurrentUser()
        if let navigationController = baseCoordinator?.presenter {
            currentUser.signOut(with: false, navigationController: navigationController, style: .indirect)
        }
    }
}

extension BaseViewController: InstallDelegate {
    
    func installModuleTap() {
        let alertController = UIAlertController(title: "Install module", message: "Tap in install module button", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alertController.addAction(action)
        self.navigationController?.present(alertController, animated: true, completion: nil)
    }
    
//    func install(_ closure: @escaping (InstallView.InstallResult) -> ()) {
//
//        let userInstall = webasyst.getUserInstall(.currentInstall)
//
//        webasyst.checkLicense(app: WebasystNetworkingParameters.install.appName, completion: { [weak self] result in
//            DispatchQueue.main.async {
//                guard let self = self else { return }
//                switch result {
//                case .success:
//                    closure(.checkLicense(.success))
//                    self.webasyst.checkInstallApp(app: WebasystNetworkingParameters.install.appName) { [weak self] install in
//                        DispatchQueue.main.async {
//                            guard let self = self else { return }
//                            switch install {
//                            case .success:
//                                closure(.checkInstallApp(.success))
//                                self.webasyst.checkUserAuth(completion: { [weak self] _ in
//                                    DispatchQueue.main.async {
//                                        guard let self = self else { return }
//                                        closure(.completed)
//                                        WebasystApp.requestFullScreenConfetti(for: self)
//                                        let replacedInstall = String.getLocalizedString(withKey: "successBody").replacingOccurrences(of: "%ACCOUNTNAME%", with: "'\(userInstall?.name ?? "unowned profile")'").replacingOccurrences(of: "%APPNAME%", with: String.appName)
//                                        self.showAlert(withTitle: .getLocalizedString(withKey: "success"),
//                                                       description: replacedInstall) { [weak self] in
//                                            DispatchQueue.main.async {
//                                                guard let self = self else { return }
//                                                self.reloadViewControllers()
//                                            }
//                                        }
//                                    }
//                                })
//                            case .failure(let error):
//                                closure(.checkInstallApp(.error))
//                                self.showAlert(withTitle: .getLocalizedString(withKey: "checkInstallAppError").replacingOccurrences(of: "%APPNAME%", with: String.appName), errorMessage: error, tryAgainBlock: true, analytics: AnalyticsModel(type: "waid", debugInfo: debug(), method: "checkInstallApp"))
//                            }
//                        }
//                    }
//                case .failure(let error):
//                    closure(.checkLicense(.error))
//                    self.showAlert(withTitle: .getLocalizedString(withKey: "checkLicenseError"), errorMessage: error, tryAgainBlock: true, analytics: AnalyticsModel(type: "waid", debugInfo: debug(), method: "checkLicense"))
//                }
//            }
//        })
//    }
}

extension BaseViewController: AddAccountDelegate {
    
    func linkAccount() {
        DispatchQueue.main.async {
            if let navigationController = self.baseCoordinator?.presenter {
                self.webasyst.mergeTwoAccs(completion: { [weak self] in
                    guard let self = self else { return }
                    switch $0 {
                    case .success(let code):
                        DispatchQueue.main.async {
                            self.webasyst.oAuthLogin(with: true, with: code, navigationController: navigationController, action: { [weak self] result in
                                guard let self = self else { return }
                                self.webasyst.mergeResultCheck(completion: { [weak self] in
                                    guard let self = self else { return }
                                    switch $0 {
                                    case .success:
                                        self.webasyst.checkUserAuth(completion: { [weak self] _ in
                                            guard let self = self else { return }
                                            DispatchQueue.main.async {
                                                navigationController.dismiss(animated: true)
                                                self.reloadViewControllers()
                                            }
                                        })
                                    case .failure:
                                        DispatchQueue.main.async {
                                            let error: String = .getLocalizedString(withKey: "mergeWelcomeError2")
                                            self.showAlert(withTitle: .getLocalizedString(withKey: "errorTitle"), description: error, analytics: AnalyticsModel(type: "waid", debugInfo: debug(), method: "oAuthLogin"))
                                        }
                                    }
                                })
                            })
                        }
                    case .failure:
                        DispatchQueue.main.async {
                            let error: String = .getLocalizedString(withKey: "mergeWelcomeError")
                            self.showAlert(withTitle: .getLocalizedString(withKey: "errorTitle"), description: error, analytics: AnalyticsModel(type: "waid", debugInfo: debug(), method: "mergeTwoAccs"))
                        }
                    }
                })
            }
        }
    }
    
    func linkAccountWithQR() {
        if let presenter = baseCoordinator?.presenter, let screens = baseCoordinator?.screens {
            let coord = QRCoordinator(presenter: presenter, screens: screens) { code in
                AddAccountNetworking.shared.connectWebasystAccount(withDigitalCode: code) { [weak self] success, id, url in
                    guard let self = self else { return }
                    if success {
                        self.webasyst.checkUserAuth(completion: { [weak self] _ in
                            guard let self = self else { return }
                            DispatchQueue.main.async {
                                presenter.presentedViewController?.dismiss(animated: true, completion: {
                                    WebasystApp.requestFullScreenConfetti(for: self)
                                    let accountName = self.webasyst.getUserInstall(.currentInstall)?.name
                                    self.showAlert(withTitle: .getLocalizedString(withKey: "success"),
                                                   description: .getLocalizedString(withKey: "connectAccountSuccessBody").replacingOccurrences(of: "%ACCOUNTNAME%", with: accountName ?? "unowned profile")) { [weak self] in
                                        guard let self = self else { return }
                                        DispatchQueue.main.async {
                                            self.reloadViewControllers()
                                        }
                                    }
                                })
                            }
                        })
                    } else {
                        DispatchQueue.main.async {
                            presenter.presentedViewController?.dismiss(animated: true, completion: {
                                self.showAlert(withTitle: .getLocalizedString(withKey: "errorTitle"), description: .getLocalizedString(withKey: "qrConnectWebasystAccountError"), errorMessage: url, analytics: AnalyticsModel(type: "waid", debugInfo: debug(), method: "connectWebasystAccount"))
                            })
                        }
                    }
                }
            }
            coord.start(.link)
        } else {
            self.showAlert(withTitle: .getLocalizedString(withKey: "errorTitle"), description: "Something went wrong with opening the QR interface.", analytics: AnalyticsModel(type: "app", debugInfo: debug(), method: "QRCoordinatorPresentation"))
        }
    }
    
    func connectAccount(withDigitalCode code: String, completion: @escaping (Bool) -> ()) {
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: activityIndicator)
        activityIndicator.startAnimating()
        AddAccountNetworking.shared.connectWebasystAccount(withDigitalCode: code) { [weak self] success, id, url in
            guard let self = self else { return }
            if success {
                self.webasyst.checkUserAuth(completion: { [weak self] _ in
                    guard let self = self else { return }
                    DispatchQueue.main.async {
                        self.navigationItem.leftBarButtonItem = nil
                        self.activityIndicator.stopAnimating()
                        WebasystApp.requestFullScreenConfetti(for: self)
                        let accountName = self.webasyst.getUserInstall(.currentInstall)?.name
                        self.showAlert(withTitle: .getLocalizedString(withKey: "success"),
                                       description: .getLocalizedString(withKey: "connectAccountSuccessBody").replacingOccurrences(of: "%ACCOUNTNAME%", with: accountName ?? "unowned profile"),
                                       errorMessage: nil,
                                       tryAgainBlock: false) { [weak self] in
                            guard let self = self else { return }
                            DispatchQueue.main.async {
                                self.reloadViewControllers()
                                completion(true)
                            }
                        }
                    }
                })
            } else {
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    completion(false)
                    self.showAlert(withTitle: .getLocalizedString(withKey: "errorTitle"), description: .getLocalizedString(withKey: "connectWebasystAccountError"), errorMessage: url, analytics: AnalyticsModel(type: "waid", debugInfo: debug(), method: "connectWebasystAccount"))
                }
            }
        }
    }
    
    func addAccount(shopDomain: String?, shopName: String?, startLoading: @escaping () -> (), stopLoading: @escaping () -> (), completion: @escaping (Bool) -> ()) {
        startLoading()
        webasyst.createWebasystAccount(bundle: WebasystNetworkingParameters.addAccount.bundle, plainId: WebasystNetworkingParameters.addAccount.planId, accountDomain: shopDomain, accountName: shopName) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .successfullyCreated(let id, _), .successfullyCreatedButNotRenamed(let id, _, _):
                UserDefaults.setCurrentInstall(withValue: id)
                DispatchQueue.main.async {
                    self.navigationItem.leftBarButtonItem = nil
                    stopLoading()
                    WebasystApp.requestFullScreenConfetti(for: self)
                    let complete: () -> () = { [weak self] in
                        DispatchQueue.main.async {
                            guard let self = self else { return }
                            self.reloadViewControllers()
                            completion(true)
                        }
                    }
                    switch result {
                    case .successfullyCreatedButNotRenamed(_, _, let renameError):
                        self.showAlert(withTitle: .getLocalizedString(withKey: "success"),
                                       description: .getLocalizedString(withKey: "addAccountSuccessButNotRenamedBody"),
                                       errorMessage: renameError,
                                       okCompletionBlock: complete)
                    default:
                        self.showAlert(withTitle: .getLocalizedString(withKey: "success"),
                                       description: .getLocalizedString(withKey: "addAccountSuccessBody"),
                                       okCompletionBlock: complete)
                    }
                }
            case .notCreated(let error):
                DispatchQueue.main.async {
                    stopLoading()
                    completion(false)
                    self.showAlert(withTitle: .getLocalizedString(withKey: "errorTitle"), description: .getLocalizedString(withKey: "createWebasystAccountError"), errorMessage: error, analytics: AnalyticsModel(type: "waid", debugInfo: debug(), method: "createWebasystAccount"))
                }
            }
        }
    }
}

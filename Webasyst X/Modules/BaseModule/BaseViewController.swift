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

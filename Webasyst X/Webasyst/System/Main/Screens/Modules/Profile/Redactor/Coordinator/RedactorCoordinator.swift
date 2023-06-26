//
//  RedactorCoordinator.swift
//  Shop-Script
//
//  Created by Леонид Лукашевич on 18.10.2022.
//

import UIKit
import Webasyst

protocol DeleteDelegate: AnyObject {
    func deleteFromAlert()
}

//MARK RedactorCoordinator
final class RedactorCoordinator {
    
    var navigationController: UINavigationController
    var screens: WebasystScreensBuilder
    var completion: (() -> Void)?
    
    weak var delegate: DeleteDelegate?
    
    init(presenter: UINavigationController, screens: WebasystScreensBuilder) {
        self.navigationController = presenter
        self.screens = screens
    }
    
    func start() {
        initialViewController()
    }
    
    private func initialViewController() {
        let viewController = screens.createRedactorViewController(coordinator: self, laterNeeded: true)
        navigationController.setViewControllers([viewController], animated: true)
    }
    
    func startImageSelector(_ viewController: UIViewController, completion: @escaping (UIImage) -> Void) {
        ImagePickerManager.shared.pickImage(viewController) { response in
            if let firstImage = response.first?.image {
                completion(firstImage)
            }
        }
    }
    
    func startFromSelector(image: UIImage?, profile: ProfileData, delegate: PassImageToPreviousController) {
        let viewController = screens.createRedactorViewController(coordinator: self, image: image, profile: profile, laterNeeded: false)
        viewController.delegate = delegate
        navigationController.pushViewController(viewController, animated: true)
    }
    
}

// MARK: - Alerts

extension RedactorCoordinator {
    
    func confirmAlertUpdatedShow(save: Bool = false,_ wasUpdated: Webasyst.Result) {
        let localizedString: String
        switch wasUpdated {
        case .success:
            localizedString = .getLocalizedString(withKey: "successfullyUpdated")
            let removeAlert = UIAlertController(title: localizedString, message: "", preferredStyle: .alert)
            removeAlert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { [weak self] _ in
                guard let self = self else { return }
                if let completion = self.completion, save {
                    completion()
                }
            }))
            self.navigationController.present(removeAlert, animated: true, completion: nil)
        case .failure(let error):
            if error is ServerError {
                localizedString = .getLocalizedString(withKey: "connectionAlertMessage")
            } else {
                localizedString = .getLocalizedString(withKey: "updateError")
            }
            let removeAlert = UIAlertController(title: localizedString, message: .getLocalizedString(withKey: "serverSentError") + "\"" + error.localizedDescription + "\"", preferredStyle: .alert)
            removeAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
                guard let self = self else { return }
                if let completion = self.completion, save {
                    completion()
                }
            }))
            self.navigationController.present(removeAlert, animated: true, completion: nil)
        }
    }
    
    func showAlert(standard: Bool = true, success: Bool = false) {
        if standard {
            let textFirst: String = .getLocalizedString(withKey: "accountDeleteFirstAlert")
            let textSecond: String = .getLocalizedString(withKey: "accountDeleteSecondAlert")
            let deleteAccount: String = .getLocalizedString(withKey: "deleteAccountConfirm")
            let cancelAccount: String = .getLocalizedString(withKey: "cacnelAccountDelete")
            let installAlert = UIAlertController(title: nil, message: textFirst, preferredStyle: .alert)
            installAlert.addAction(UIAlertAction(title: cancelAccount, style: .cancel, handler: nil))
            installAlert.addAction(UIAlertAction(title: deleteAccount, style: .destructive, handler: { [weak self] _ in
                guard let self = self else { return }
                let installAlert = UIAlertController(title: nil, message: textSecond, preferredStyle: .alert)
                installAlert.addAction(UIAlertAction(title: cancelAccount, style: .cancel, handler: nil))
                installAlert.addAction(UIAlertAction(title: deleteAccount, style: .destructive, handler: { [weak self] _ in
                    guard let self = self else { return }
                    self.delegate?.deleteFromAlert()
                }))
                self.navigationController.present(installAlert, animated: true, completion: nil)
            }))
            navigationController.present(installAlert, animated: true, completion: nil)
        } else {
            let error: String = .getLocalizedString(withKey: "accountDeleteError")
            let successText: String = .getLocalizedString(withKey: "accountWasDeleted")
            let installerAlert = UIAlertController(title: nil, message: success ? successText : error, preferredStyle: .alert)
            installerAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { _ in
                let currentUser = CurrentUser()
                currentUser.signOut(with: false, navigationController: self.navigationController, style: .indirect)
            }))
            self.navigationController.present(installerAlert, animated: true, completion: nil)
        }
    }
    
}

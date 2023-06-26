//
//  PasscodeSettingsViewController.swift
//  Cashflow
//
//  Created by Andrey Leganov on 4/14/21.
//

import UIKit

class PasscodeSettingsViewController {
    
    // MARK: - Parameters
    
    private weak var presenter: UINavigationController?
    private let configuration: PasscodeLockConfigurationType
    
    private let localizedOnTitle: String = .getLocalizedString(withKey: "localizedOnTitle")
    private let localizedOffTitle: String = .getLocalizedString(withKey: "localizedOffTitle")
    private let localizedChangeTitle: String = .getLocalizedString(withKey: "localizedChangeTitle")
    
    public var onOffTitle: String {
        if !configuration.repository.hasPasscode {
            return localizedOnTitle
        } else {
            return localizedOffTitle
        }
    }
    
    public var changeTitle: String {
        return localizedChangeTitle
    }
    
    // MARK: - Init
    
    init(presenter: UINavigationController?, configuration: PasscodeLockConfigurationType) {
        
        self.presenter = presenter
        self.configuration = configuration
    }
    
    // MARK: - Methods
    
    public func getAlertController() -> UIAlertController {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let onOffAction = UIAlertAction(title: self.onOffTitle, style: .default) { [weak self] _ in
            self?.onOffButtonTapped()
        }
        let changeAction = UIAlertAction(title: self.changeTitle, style: .default) { [weak self] _ in
            self?.changeButtonTapped()
        }
        let cancelAction = UIAlertAction(title: .getLocalizedString(withKey: "cancel"), style: .cancel) { _ in
            alert.dismiss(animated: true)
        }
        onOffAction.setValue(UIColor.appColor, forKey: "titleTextColor")
        changeAction.setValue(UIColor.appColor, forKey: "titleTextColor")
        cancelAction.setValue(UIColor.appColor, forKey: "titleTextColor")
        
        if !configuration.repository.hasPasscode {
            alert.addAction(onOffAction)
        } else {
            alert.addAction(changeAction)
            alert.addAction(onOffAction)
        }
        alert.addAction(cancelAction)
        
        return alert
    }
    
    // MARK: - Actions
    
    public func onOffButtonTapped() {
        
        let passcodeVC: PasscodeLockViewController
        
        if !configuration.repository.hasPasscode {
            passcodeVC = PasscodeLockViewController(state: .SetPasscode, configuration: configuration)
        } else {
            passcodeVC = PasscodeLockViewController(state: .RemovePasscode, configuration: configuration)
            passcodeVC.successCallback = { lock in
                lock.repository.deletePasscode()
            }
        }
        
        presenter?.pushViewController(passcodeVC, animated: true)
    }
    
    public func changeButtonTapped() {
        
        let repo = UserDefaultsPasscodeRepository()
        let config = PasscodeLockConfiguration(repository: repo)
        
        let passcodeVC = PasscodeLockViewController(state: .ChangePasscode, configuration: config)

        presenter?.pushViewController(passcodeVC, animated: true)
    }
}

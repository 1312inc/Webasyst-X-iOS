//
//  PasscodeDelegate.swift
//  Shop-Script
//
//  Created by Леонид Лукашевич on 06.04.2023.
//

import UIKit

class PasscodeActionDelegate: NSObject {
    
    unowned let presenter: UIWindow
    private var passcodeSkiped: (() -> ())?
    private var passcodeSuccessed: (() -> ())?
    
    init(presenter: UIWindow) {
        self.presenter = presenter
    }
    
    func configurePasscodeActions(passcodeSkiped: @escaping () -> (), passcodeSuccessed: @escaping () -> ()) {
        self.passcodeSkiped = passcodeSkiped
        self.passcodeSuccessed = passcodeSuccessed
    }
    
    func showPasscodeLockView() {
            
        let repo = UserDefaultsPasscodeRepository()
        let config = PasscodeLockConfiguration(repository: repo)
        
        if config.repository.hasPasscode, !(presenter.rootViewController is PasscodeLockViewController) {
            
            let passcodeLock = PasscodeLockViewController(state: .EnterPasscode, configuration: config)
            
            presenter.rootViewController = passcodeLock
            presenter.backgroundColor = .reverseLabel
            NotificationCenter.default.addObserver(self, selector: #selector(passcodeSuccess), name: .passcodeLockDidSucceed, object: nil)
        } else {
            UserDefaults.standard.set(true, forKey: UserDefaults.passcodeIsSuccessed)
            passcodeSkiped?()
        }
    }
    
    @objc
    private func passcodeSuccess() {
        UserDefaults.standard.set(true, forKey: UserDefaults.passcodeIsSuccessed)
        NotificationCenter.default.removeObserver(self, name: .passcodeLockDidSucceed, object: nil)
        passcodeSuccessed?()
    }
}

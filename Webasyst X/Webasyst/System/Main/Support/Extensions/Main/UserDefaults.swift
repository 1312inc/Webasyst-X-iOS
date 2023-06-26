//
//  UserDefaultExtension.swift
//  Shop-Script
//
//  Created by Леонид Лукашевич on 05.04.2023.
//

import Foundation

extension UserDefaults {
    
    static var activeSettingClientId = "selectDomainUser"
    static var passcodeIsSuccessed = "passcodeIsSuccessed"
    static var biometricAuthInProgress = "biometricAuthInProgress"
    static var launchCount = "launchCount"

    // MARK: - Current Install
    
    static func getCurrentInstall() -> String {
        return UserDefaults.standard.string(forKey: UserDefaults.activeSettingClientId) ?? ""
    }
    
    static func setCurrentInstall(withValue value: String?) {
        UserDefaults.standard.set(value, forKey: UserDefaults.activeSettingClientId)
    }
    
    // MARK: - Passcode
    
    static func passcodeCheckIsNeeded() -> Bool {
        
        let hasPasscode = UserDefaultsPasscodeRepository().hasPasscode
        let biometricAuthInProgress = UserDefaults.getBiometricAuthInProgress()
        
        return hasPasscode && !biometricAuthInProgress
    }
    
    private static func hasPasscode() -> Bool {
        let repo = UserDefaultsPasscodeRepository()
        return repo.hasPasscode
    }
    
    static func getBiometricAuthInProgress() -> Bool {
        return UserDefaults.standard.bool(forKey: UserDefaults.biometricAuthInProgress)
    }
    
    static func setBiometricAuthInProgress(_ value: Bool) {
        UserDefaults.standard.set(value, forKey: UserDefaults.biometricAuthInProgress)
    }
}

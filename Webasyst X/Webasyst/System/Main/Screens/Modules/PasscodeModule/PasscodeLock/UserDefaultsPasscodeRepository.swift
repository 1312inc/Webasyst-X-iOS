//
//  UserDefaultsPasscodeRepository.swift
//  Cashflow
//
//  Created by Andrey Leganov on 4/14/21.
//

import Foundation

class UserDefaultsPasscodeRepository: PasscodeRepositoryType {
    
    private let passcodeKey = "passcode.lock.passcode"
    
    private lazy var defaults: UserDefaults = {
        
        return UserDefaults.standard
    }()
    
    var hasPasscode: Bool {
        
        if passcode != nil {
            return true
        }
        
        return false
    }
    
    var passcode: [String]? {
        
        return defaults.value(forKey: passcodeKey) as? [String] ?? nil
    }
    
    func savePasscode(passcode: [String]) {
        
        defaults.set(passcode, forKey: passcodeKey)
        defaults.synchronize()
    }
    
    func deletePasscode() {
        
        defaults.removeObject(forKey: passcodeKey)
        defaults.synchronize()
    }
}

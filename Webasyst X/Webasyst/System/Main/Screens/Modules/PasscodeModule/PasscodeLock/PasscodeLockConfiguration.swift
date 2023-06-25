//
//  PasscodeLockConfiguration.swift
//  Cashflow
//
//  Created by Andrey Leganov on 4/14/21.
//

import Foundation

struct PasscodeLockConfiguration: PasscodeLockConfigurationType {
    
    let repository: PasscodeRepositoryType
    let passcodeLength = 4
    var isBiometricAuthAllowed = true
    let shouldRequestBiometricAuthImmediately = true
    var biometricAuthReason: String? = nil
    let maximumInccorectPasscodeAttempts = -1
    
    init(repository: PasscodeRepositoryType) {
        
        self.repository = repository
    }
    
    init() {
        
        self.repository = UserDefaultsPasscodeRepository()
    }
}

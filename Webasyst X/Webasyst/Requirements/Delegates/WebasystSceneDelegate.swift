//
//  WebasystSceneDelegate.swift
//  Shop-Script
//
//  Created by Леонид Лукашевич on 06.04.2023.
//

import Foundation

protocol WebasystSceneDelegate {
    var webasystSceneManager: WebasystSceneManager! { get }
}

class WebasystSceneManager: PasscodeMangerDelegate {
    
    var passcodeManager: PasscodeManager!
    
    init(activatePasscodeLock: @escaping () -> ()) {
        passcodeManager = PasscodeManager(activatePasscodeLock: activatePasscodeLock)
    }
}

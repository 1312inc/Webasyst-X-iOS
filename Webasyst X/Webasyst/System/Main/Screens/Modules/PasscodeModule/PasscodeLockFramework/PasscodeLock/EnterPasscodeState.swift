//
//  EnterPasscodeState.swift
//  PasscodeLock
//
//  Created by Yanko Dimitrov on 8/28/15.
//  Copyright © 2015 Yanko Dimitrov. All rights reserved.
//

import Foundation

public let PasscodeLockIncorrectPasscodeNotification = "passcode.lock.incorrect.passcode.notification"

struct EnterPasscodeState: PasscodeLockStateType {
    
    let title: String
    let description: String
    let isCancellableAction: Bool
    var isBiometricAuthAllowed = true
    
    private var inccorectPasscodeAttempts = 0
    private var isNotificationSent = false
    
    init(allowCancellation: Bool = false) {
        
        isCancellableAction = allowCancellation
        if allowCancellation {
            title = localizedStringFor(key: "PasscodeLockRemoveTitle", comment: "Remove passcode title")
            description = localizedStringFor(key: "PasscodeLockRemoveDescription", comment: "Remove passcode description")
        } else {
            title = localizedStringFor(key: "PasscodeLockEnterTitle", comment: "Enter passcode title")
            description = localizedStringFor(key: "PasscodeLockEnterDescription", comment: "Enter passcode description")
        }
    }
    
    mutating func acceptPasscode(passcode: [String], fromLock lock: PasscodeLockType) {
        
        guard let currentPasscode = lock.repository.passcode else {
            return
        }
        
        if passcode == currentPasscode {
            
            lock.delegate?.passcodeLockDidSucceed(lock: lock)
            
        } else {
            
            inccorectPasscodeAttempts += 1
            
            if inccorectPasscodeAttempts >= lock.configuration.maximumInccorectPasscodeAttempts {
                
                postNotification()
            }
            
            lock.delegate?.passcodeLockDidFail(lock: lock)
        }
    }
    
    private mutating func postNotification() {
        
        guard !isNotificationSent else { return }
            
        let center = NotificationCenter.default
        
        center.post(name: NSNotification.Name(rawValue: PasscodeLockIncorrectPasscodeNotification), object: nil)
        
        isNotificationSent = true
    }
}

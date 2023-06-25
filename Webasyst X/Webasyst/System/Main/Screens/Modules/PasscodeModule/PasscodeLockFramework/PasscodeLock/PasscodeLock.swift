//
//  PasscodeLock.swift
//  PasscodeLock
//
//  Created by Yanko Dimitrov on 8/28/15.
//  Copyright © 2015 Yanko Dimitrov. All rights reserved.
//

import Foundation
import LocalAuthentication

public class PasscodeLock: PasscodeLockType {
    
    public weak var delegate: PasscodeLockTypeDelegate?
    public let configuration: PasscodeLockConfigurationType
    
    public var repository: PasscodeRepositoryType {
        return configuration.repository
    }
    
    public var state: PasscodeLockStateType {
        return lockState
    }
    
    public var isBiometricAuthAllowed: Bool {
        return isBiometricAuthEnabled() && configuration.isBiometricAuthAllowed && lockState.isBiometricAuthAllowed
    }
    
    public var passcodeIsEmpty: Bool {
        return passcode.isEmpty
    }
    
    private var lockState: PasscodeLockStateType
    private lazy var passcode = [String]()
    
    public init(state: PasscodeLockStateType, configuration: PasscodeLockConfigurationType) {
        
        precondition(configuration.passcodeLength > 0, "Passcode length sould be greather than zero.")
        
        self.lockState = state
        self.configuration = configuration
    }
    
    public func addSign(sign: String) {
        
        passcode.append(sign)
        delegate?.passcodeLock(lock: self, addedSignAtIndex: passcode.count - 1)
        
        if passcode.count >= configuration.passcodeLength {
            
            lockState.acceptPasscode(passcode: passcode, fromLock: self)
            passcode.removeAll(keepingCapacity: true)
        }
    }
    
    public func removeSign() {
        
        guard passcode.count > 0 else { return }
        
        passcode.removeLast()
        delegate?.passcodeLock(lock: self, removedSignAtIndex: passcode.count)
    }
    
    public func changeStateTo(state: PasscodeLockStateType) {
        DispatchQueue.main.async {
            self.lockState = state
            self.delegate?.passcodeLockDidChangeState(lock: self)
        }
    }
    
    public func authenticateWithBiometrics() {
        
        guard isBiometricAuthAllowed else { return }
        
        let context = LAContext()
        let reason: String
        
        if let configReason = configuration.biometricAuthReason {
            reason = configReason
        } else {
            if #available(iOS 11, *) {
                 switch(context.biometryType) {
                 case .touchID:
                    reason = localizedStringFor(key: "PasscodeLockTouchIDReason", comment: "Authentication required to proceed")
                 case .faceID:
                    reason = localizedStringFor(key: "PasscodeLockFaceIDReason", comment: "Authentication required to proceed")
                 default:
                    reason = localizedStringFor(key: "PasscodeLockBiometricAuthReason", comment: "Authentication required to proceed")
                 }
             } else {
                reason = localizedStringFor(key: "PasscodeLockBiometricAuthReason", comment: "Authentication required to proceed")
             }
        }
        context.localizedFallbackTitle = localizedStringFor(key: "PasscodeLockBiometricAuthButton", comment: "Biometric authentication fallback button")
        
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
            success, error in
            
            self.handleBiometricAuthResult(success: success)
        }
    }
    
    private func handleBiometricAuthResult(success: Bool) {
        
        DispatchQueue.main.async() {
            
            UserDefaults.setBiometricAuthInProgress(false)
            
            if success {
                
                self.delegate?.passcodeLockDidSucceed(lock: self)
            }
        }
    }
    
    private func isBiometricAuthEnabled() -> Bool {
        
        let context = LAContext()
        
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }
}

//
//  PasscodeLockType.swift
//  PasscodeLock
//
//  Created by Yanko Dimitrov on 8/28/15.
//  Copyright © 2015 Yanko Dimitrov. All rights reserved.
//

import Foundation

public protocol PasscodeLockType {
    
    var delegate: PasscodeLockTypeDelegate? { get set }
    var configuration: PasscodeLockConfigurationType { get }
    var repository: PasscodeRepositoryType { get }
    var state: PasscodeLockStateType { get }
    var isBiometricAuthAllowed: Bool { get }
    var passcodeIsEmpty: Bool { get }
    
    func addSign(sign: String)
    func removeSign()
    func changeStateTo(state: PasscodeLockStateType)
    func authenticateWithBiometrics()
}

public protocol PasscodeLockTypeDelegate: AnyObject {
    
    func passcodeLockDidSucceed(lock: PasscodeLockType)
    func passcodeLockDidFail(lock: PasscodeLockType)
    func passcodeLockDidChangeState(lock: PasscodeLockType)
    func passcodeLock(lock: PasscodeLockType, addedSignAtIndex index: Int)
    func passcodeLock(lock: PasscodeLockType, removedSignAtIndex index: Int)
}

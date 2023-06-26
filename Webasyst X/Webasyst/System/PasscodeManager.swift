//
//  SceneDelegatePasscode.swift
//  Shop-Script
//
//  Created by Леонид Лукашевич on 06.04.2023.
//

import UIKit

protocol PasscodeMangerDelegate {
    var passcodeManager: PasscodeManager! { get }
}

class PasscodeManager {
    
    private var passcodeTimer = Timer()
    private var passcodeBackgroundTask: UIBackgroundTaskIdentifier = .invalid
    private var isTimeUp: Bool = false
    
    private var activatePasscodeLock: () -> ()
    
    init(activatePasscodeLock: @escaping () -> ()) {
        self.activatePasscodeLock = activatePasscodeLock
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    @objc
    func willResignActive() {
        startPasscodeLockBackgroundTask()
    }
    
    @objc
    func didBecomeActive() {
        passcodeTimer.invalidate()
        endPasscodeLockBackgroundTask()
        if isTimeUp {
            activatePasscodeLock()
        }
    }
    
    private func startPasscodeLockBackgroundTask() {
        DispatchQueue.global().async {
            self.registerPasscodeLockBackgroundTask()
            self.isTimeUp = false
            if UserDefaults.standard.bool(forKey: UserDefaults.passcodeIsSuccessed) {
                self.passcodeTimer = Timer.scheduledTimer(timeInterval: 5 * 60, target: self, selector: #selector(self.timerReset), userInfo: nil, repeats: false)
                RunLoop.current.add(self.passcodeTimer, forMode: RunLoop.Mode.default)
                RunLoop.current.run()
            }
        }
    }
    
    func registerPasscodeLockBackgroundTask() {
        passcodeBackgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endPasscodeLockBackgroundTask()
        }
        assert(passcodeBackgroundTask != .invalid)
    }
    
    func endPasscodeLockBackgroundTask() {
        UIApplication.shared.endBackgroundTask(passcodeBackgroundTask)
        passcodeBackgroundTask = .invalid
    }
    
    @objc private func timerReset() {
        UserDefaults.standard.set(false, forKey: UserDefaults.passcodeIsSuccessed)
        isTimeUp = true
        passcodeTimer.invalidate()
        endPasscodeLockBackgroundTask()
    }
}

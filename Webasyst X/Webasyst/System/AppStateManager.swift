//
//  SceneDelegatePasscode.swift
//  Shop-Script
//
//  Created by Леонид Лукашевич on 06.04.2023.
//

import UIKit

protocol AppStateDelegate {
    var appStateManager: AppStateManager! { get }
}

class AppStateManager {
    
    private var timer: DispatchSourceTimer?
    
    private var openClosure: () -> ()
    private var closeClosure: () -> ()
    private var checkInstallsClosure: () -> ()
    
    init(openClosure: @escaping () -> (), closeClosure: @escaping () -> (), checkInstallsClosure: @escaping () -> ()) {
        
        self.openClosure = openClosure
        self.closeClosure = closeClosure
        self.checkInstallsClosure = checkInstallsClosure
        
        UserDefaults.standard.set(false, forKey: UserDefaults.passcodeIsSuccessed)
        UserDefaults.setBiometricAuthInProgress(false)
        
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillTerminate), name: UIApplication.willTerminateNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(passcodeSuccess), name: .passcodeLockDidSucceed, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willTerminateNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: .passcodeLockDidSucceed, object: nil)
    }
    
    @objc
    private func passcodeSuccess() {
        UserDefaults.standard.set(true, forKey: UserDefaults.passcodeIsSuccessed)
    }
    
    private func bringBlur(withAnimation animation: Bool) {
        let application = UIApplication.shared
        guard let window = application.keyWindow,
              application.applicationState != .active else { return }
        let isTherePasscodeLockViewController = window.rootViewController?.isThere(PasscodeLockViewController.self) ?? false
        if !isTherePasscodeLockViewController && UserDefaults.passcodeCheckIsNeeded() {
            for subview in window.subviews.filter({ $0 is BlurryView }) {
                (subview as? BlurryView)?.remove(withAnimation: false)
            }
            let blurryView = BlurryView(frame: window.bounds)
            window.addSubview(blurryView)
            blurryView.bring(withAnimation: animation)
        }
    }
    
    private func removeBlur() {
        if UserDefaults.standard.bool(forKey: UserDefaults.passcodeIsSuccessed) {
            let application = UIApplication.shared
            guard let window = application.keyWindow else { return }
            for subview in window.subviews.filter({ $0 is BlurryView }) {
                (subview as? BlurryView)?.remove(withAnimation: true)
            }
        }
    }
    
    @objc
    func appDidBecomeActive() {
        
        DispatchQueue.main.async {
            self.removeBlur()
            self.stopDispatchTimer()
        }
    }
    
    @objc
    func appWillResignActive() {
        
        if timer == nil {
            timer = DispatchSource.makeTimerSource(queue: .main)
            timer?.schedule(deadline: .now() + 5)
            timer?.setEventHandler(handler: {
                self.bringBlur(withAnimation: true)
                self.stopDispatchTimer()
            })
            timer?.resume()
        }
    }
    
    @objc
    func appWillEnterForeground() {
        
        DispatchQueue.main.async {
            self.removeBlur()
            self.stopDispatchTimer()
            
            self.checkInstallsClosure()
            self.openClosure()
        }
        
        DispatchQueue.global().async {
            let launchCountV = UserDefaults.standard.integer(forKey: UserDefaults.launchCount)
            UserDefaults.standard.setValue(launchCountV + 1, forKey: UserDefaults.launchCount)
        }
    }
    
    @objc
    func appDidEnterBackground() {
        self.bringBlur(withAnimation: false)
        self.stopDispatchTimer()
        self.closeClosure()
    }
    
    @objc
    func appWillTerminate() {
        self.closeClosure()
    }
    
    private func stopDispatchTimer() {
        timer?.cancel()
        timer = nil
    }
}

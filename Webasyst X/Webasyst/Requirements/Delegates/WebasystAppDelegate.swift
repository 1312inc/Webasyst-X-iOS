//
//  WebasystAppDelegate.swift
//  Shop-Script
//
//  Created by Леонид Лукашевич on 06.04.2023.
//

import Foundation
import Webasyst

protocol WebasystAppDelegate {
    var webasystAppManager: WebasystAppManager! { get }
}

class WebasystAppManager: AppStateDelegate {
    
    var appStateManager: AppStateManager!
    let webasyst = WebasystApp()
    
    private var currentInstall: String? = .currentInstall
    
    init(openClosure: @escaping () -> () = {}, closeClosure: @escaping () -> () = {}) {
        
        appStateManager = AppStateManager(openClosure: openClosure, closeClosure: closeClosure, checkInstallsClosure: { [weak self] in self?.checkUserInstalls() })
        
        DispatchQueue.global().async {
            self.webasyst.configure()
        }
        
        startUserInstallUpdatingTimer()
    }
    
    func startUserInstallUpdatingTimer() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 60 * 5, execute: {
            self.checkUserInstalls()
            self.startUserInstallUpdatingTimer()
        })
    }
    
    func checkUserInstalls() {
        self.currentInstall = .currentInstall
        webasyst.updateUserInstalls { [weak self] installs in
            guard let self = self else { return }
            if let installs = installs {
                self.processUserInstalls(count: installs.count)
            }
        }
    }
    
    private func processUserInstalls(count: Int) {
        if count == 0 {
            NotificationCenter.postMessage(.withoutInstalls)
        } else if let currentInstall = currentInstall, (currentInstall != .currentInstall) {
            NotificationCenter.postMessage(.accountSwitched)
        }
    }
}

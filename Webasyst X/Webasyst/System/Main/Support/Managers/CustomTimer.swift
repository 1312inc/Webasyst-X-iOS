//
//  TimerForSettings.swift
//  Shop-Script
//
//  Created by Леонид Лукашевич on 09.11.2022.
//

import Foundation

final class CustomTimer {
    
    static let shared = CustomTimer()
    private init() {}
    
    var timer: Timer?
    
    func startTimer(atTimeInSeconds time: Double) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: time, repeats: false, block: { timer in
            timer.invalidate()
        })
    }
    
    func stopTimer() {
        timer?.invalidate()
    }
    
    func isValidTimer() -> Bool? {
        return timer?.isValid
    }
    
}

final class CustomTimerForAnalytics {
    
    static let shared = (forOrders: CustomTimerForAnalytics(), forProducts: CustomTimerForAnalytics())
    private init() {}
    
    var timer: Timer?
    
    func startTimer(atTimeInSeconds time: Double, completion: @escaping () -> () = {}) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: time, repeats: false, block: { timer in
            completion()
            timer.invalidate()
        })
    }
    
    func stopTimer() {
        timer?.invalidate()
    }
    
    func isValidTimer() -> Bool? {
        return timer?.isValid
    }
    
}


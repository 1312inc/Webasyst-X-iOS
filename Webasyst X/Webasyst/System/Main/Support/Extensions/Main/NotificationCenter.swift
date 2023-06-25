//
//  NotificationCenter.swift
//  Shop-Script
//
//  Created by Леонид Лукашевич on 11.04.2023.
//

import Foundation

extension NotificationCenter {
    
    enum MessageType {
        case withoutInstalls
        case accountSwitched
    }
    
    static func postMessage(_ type: MessageType) {
        switch type {
        case .withoutInstalls:
            NotificationCenter.default.post(name: Service.Notify.withoutInstalls, object: nil)
        case .accountSwitched:
            NotificationCenter.default.post(name: Service.Notify.accountSwitched, object: nil)
        }
    }
}

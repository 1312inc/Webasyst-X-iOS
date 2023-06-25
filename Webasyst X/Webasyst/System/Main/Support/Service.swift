//
//  Service.swift
//  Shop-Script
//
//  Created by Леонид Лукашевич on 05.04.2023.
//

import Foundation
import Webasyst

enum Service {
    
    enum Notify {
        
        static var accountSwitched: Notification.Name {
            Notification.Name("accountHasBeenSwitched")
        }
        
        static var withoutInstalls: Notification.Name {
            Notification.Name("withoutInstalls")
        }
        
        static var update: Notification.Name {
            Notification.Name("update")
        }
        
        static var orientation: Notification.Name {
            NSNotification.Name("orientation")
        }
        
        static var navigationBar: Notification.Name {
            NSNotification.Name("navigationBar")
        }
        
    }
    
    enum Colors {
        
        static var reverseLabel: String {
            "labelReverseColor"
        }
        
        static var cellColor: String {
            "cellListBackgroundColor"
        }
        
        static var tintColor: String {
            "addButtonColor"
        }
        
        static func color(_ color: String?) -> UIColor {
            if let colorSequence = color?.dropFirst(2) {
                let textColor = String(colorSequence)
                if let color = UIColor(named: textColor) {
                    return color
                } else {
                    return .reverseLabel
                }
            } else {
                return .reverseLabel
            }
        }
        
    }
    
    enum Demo {
        static var isDemo = false
        static var demoToken = "5f9db4d32d9a586c2daca4b45de23eb8"
    }
    
    enum NoAvatar {
        static var stringUrl = "/wa-content/img/userpic96@2x.jpg"
    }
}

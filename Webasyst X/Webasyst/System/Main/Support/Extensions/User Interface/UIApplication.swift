//
//  UIApplication.swift
//  Shop-Script
//
//  Created by Леонид Лукашевич on 05.04.2023.
//

import UIKit

extension UIApplication {
    
    var keyWindow: UIWindow? {
        if #available(iOS 15.0, *) {
            return self.connectedScenes.compactMap { ($0 as? UIWindowScene)?.keyWindow }.first
        } else {
            return self.windows.filter({ $0.isKeyWindow }).first
        }
    }
    
    class func topViewController(_ viewController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = viewController as? UINavigationController {
            return topViewController(nav.visibleViewController)
        }
        if let tab = viewController as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(selected)
            }
        }
        if let presented = viewController?.presentedViewController {
            return topViewController(presented)
        }
        return viewController
    }
}

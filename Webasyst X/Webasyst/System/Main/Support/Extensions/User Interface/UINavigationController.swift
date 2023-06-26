//
//  UINavigationController.swift
//  Shop-Script
//
//  Created by Леонид Лукашевич on 05.10.2022.
//

import UIKit

extension UINavigationController {
    
    func appearanceColor(color: UIColor?) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = color
        self.navigationBar.standardAppearance = appearance
    }
    
    func clearAppearance() {
        self.navigationBar.standardAppearance = .init()
    }
}


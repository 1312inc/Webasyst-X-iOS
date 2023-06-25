//
//  UIColor.swift
//  Shop-Script
//
//  Created by Леонид Лукашевич on 05.04.2023.
//

import UIKit

extension UIColor {
    
    static let appColor = UIColor(named: "appColor")!
    
    static let backgroundColor = UIColor(named: "backgroundColor")!
    static let reverseLabel = UIColor(named: Service.Colors.reverseLabel) ?? .label
}

extension UIColor {
    
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")

        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}

//
//  UIFont.swift
//  Shop-Script
//
//  Created by Леонид Лукашевич on 03.10.2022.
//

import UIKit

extension UIFont {
    
    class func adaptiveFont(_ style: UIFont.TextStyle, _ size: CGFloat, _ weight: UIFont.Weight = .regular) -> UIFont {
        UIFontMetrics(forTextStyle: style).scaledFont(for: .systemFont(ofSize: size, weight: weight))
    }
    
}

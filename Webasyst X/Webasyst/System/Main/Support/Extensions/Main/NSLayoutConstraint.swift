//
//  NSLayoutConstraint.swift
//  Shop-Script
//
//  Created by Леонид Лукашевич on 07.02.2023.
//

import UIKit

extension NSLayoutConstraint {
    
    func changeConstraint(withMultiplier multiplier: CGFloat) -> NSLayoutConstraint {
        
        let newConstraint = NSLayoutConstraint(item: self.firstItem!, attribute: self.firstAttribute,
                                               relatedBy: self.relation, toItem: self.secondItem,
                                               attribute: self.secondAttribute, multiplier: multiplier, constant: self.constant)
        
        self.isActive = false
        newConstraint.isActive = true
        
        return newConstraint
    }
}

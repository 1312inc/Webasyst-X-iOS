//
//  FloatingPoint.swift
//  Shop-Script
//
//  Created by Леонид Лукашевич on 06.02.2023.
//

import Foundation

extension FloatingPoint {
    
    var whole: Self { modf(self).0 }
    var fraction: Self { modf(self).1 }
    
    var isInteger: Bool {
        if (self.fraction * 1000).whole == 9 {
            return false
        } else {
            let fraction = (self.fraction * 100).whole
            if fraction == 0 || fraction > 99 { return true } else { return false }
        }
    }
}

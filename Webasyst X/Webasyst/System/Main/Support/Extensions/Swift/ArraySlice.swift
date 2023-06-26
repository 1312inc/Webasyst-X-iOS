//
//  ArraySlice.swift
//  Shop-Script
//
//  Created by Леонид Лукашевич on 07.04.2023.
//

import Foundation

extension ArraySlice {
    
    func asArray() -> [Element] {
        self.reduce([Element](), { $0 + [$1] })
    }
    
}

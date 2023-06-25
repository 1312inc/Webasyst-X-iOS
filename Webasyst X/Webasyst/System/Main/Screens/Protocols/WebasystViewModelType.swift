//
//  Protocols.swift
//  Shop-Script
//
//  Created by Леонид Лукашевич on 05.04.2023.
//

import UIKit

protocol WebasystViewModelType {
    associatedtype Input
    associatedtype Output
    var input: Input { get }
    var output: Output { get }
}

//
//  ServerError.swift
//  Shop-Script
//
//  Created by Леонид Лукашевич on 05.04.2023.
//

import Foundation

enum ServerError: Error, Equatable {
    case withoutError
    case notEntity
    case requestFailed(text: String)
    case missingToken(text: String)
    case notInstall
    case withoutInstalls
    case accessDenied
    case notConnection
}

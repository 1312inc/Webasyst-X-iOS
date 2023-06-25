//
//  NetworkingResult.swift
//  Shop-Script
//
//  Created by Леонид Лукашевич on 05.04.2023.
//

import Foundation

enum NetworkingResult<Value> {
    case success(Value)
    case error(ServerError)
    
    func get() throws -> Value {
        switch self {
        case .success(let value):
            return value
        case .error(let serverError):
            throw serverError
        }
    }    
}


//
//  Result.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 1/26/21.
//

import Foundation

enum Result<Value> {
    case Success(Value)
    case Failure(CustomError)
}

enum CustomError {
    case permisionDenied
    case notEntity
    case requestFailed
}

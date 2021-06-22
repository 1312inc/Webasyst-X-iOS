//
//  Result.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 1/26/21.
//

import Foundation

enum Result<Value> {
    case Success(Value)
    case Failure(ServerError)
}

enum ServerError {
    case permisionDenied
    case notEntity
    case requestFailed(text: String)
    case notInstall
}

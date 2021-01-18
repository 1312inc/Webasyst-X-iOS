//
//  UserData.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 1/18/21.
//

import Foundation

struct UserData: Codable {
    let name: String
    let email: [Email]
    let userpic: String
}

struct Email: Codable {
    let value: String
}

//
//  UserToken.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 1/18/21.
//

import Foundation

struct UserToken: Codable {
    let access_token: String
    let token_type: String
    let expires_in: Int
    let refresh_token: String
}

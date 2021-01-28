//
//  InstallListModel.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 1/18/21.
//

import Foundation

struct InstallList: Codable {
    let id: String
    let domain: String
    let url: String
}

struct UserData: Codable {
    let name: String
    let firstname: String
    let lastname: String
    let middlename: String
    let email: [Email]
    let userpic_original_crop: String
}

struct Email: Codable {
    let value: String
}

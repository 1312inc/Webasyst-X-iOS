//
//  AddAccountModel.swift
//  Shop-Script
//
//  Created by Леонид Лукашевич on 18.10.2022.
//

import Foundation

struct NewShopModel {
    let domain: String?
    let name: String?
}

enum AddAccountResult {
    case success(accountName: String?)
    case error(description: String?)
}

//
//  WebasystNetworking.swift
//  Shop-Script
//
//  Created by Леонид Лукашевич on 06.04.2023.
//

import Foundation

struct WebasystNetworkingParameters {
    static let addAccount = AddAccount(bundle: "allwebasyst", planId: "TRIAL")
    static let install = Install(appName: "shop")
}

extension WebasystNetworkingParameters {
    
    struct AddAccount {
        let bundle: String
        let planId: String
    }
    
    struct Install {
        let appName: String
    }
}

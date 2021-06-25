//
//  DetailSiteModel.swift
//  Webasyst X
//
//  Created by Виктор Кобыхно on 25.06.2021.
//

import Foundation

// MARK: - DetailSite
struct DetailSite: Codable {
    let id, name: String
    let title, content: String
    let update_datetime: String?
}

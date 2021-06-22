//
//  SiteModel.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 1/27/21.
//

import Foundation

struct SiteList: Decodable {
    var pages: [Pages]?
}

struct Pages: Decodable {
    var id: String
    var name: String
    var title: String
    var full_url: String
    var url: String
    var create_datetime: String
    var update_datetime: String
    var status: String
}

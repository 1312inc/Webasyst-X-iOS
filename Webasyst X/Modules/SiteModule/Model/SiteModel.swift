//
//  Site module - SiteModel.swift
//  Webasyst-X-iOS
//
//  Created by viktkobst on 26/07/2021.
//  Copyright © 2021 1312 Inc.. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

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

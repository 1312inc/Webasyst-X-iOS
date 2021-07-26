//
//  SiteDetail module - SiteDetailModel.swift
//  Webasyst-X-iOS
//
//  Created by viktkobst on 26/07/2021.
//  Copyright © 2021 1312 Inc.. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

// MARK: - DetailSite
struct DetailSite: Codable {
    let id, name: String
    let title, content: String
    let update_datetime: String?
}

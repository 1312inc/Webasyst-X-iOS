//
//  NewBlog module - NewBlogModel.swift
//  Webasyst-X-iOS
//
//  Created by viktkobst on 26/07/2021.
//  Copyright © 2021 1312 Inc.. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

// MARK: - BlogPost
struct PostsBlog: Codable {
    let count, offset, limit: Int?
    let posts: [PostList]?
}

// MARK: - Post
struct PostList: Codable {
    let id, blogID: String?
    let datetime, title: String
    let text: String
    let icon: String?
    let user: PostAuthor?

    enum CodingKeys: String, CodingKey {
        case id, icon
        case blogID = "blog_id"
        case datetime, title, text
        case user
    }
}

// MARK: - User
struct PostAuthor: Codable {
    let id: String?
    let name: String?
    let firstname: String?
    let middlename: String?
    let lastname: String?
    let isCompany, photo: String?
    let postsLink: String?
    let photo_url_20: String?
}

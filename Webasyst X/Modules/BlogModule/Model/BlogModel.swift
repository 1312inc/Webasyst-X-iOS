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

struct PostsBlog: Codable, Equatable {
    let posts: [PostList]?
}

struct PostList: Codable, Equatable {
    let id: String
    let blog_id: String
    let datetime: String
    let title: String
    let text: String
    let comment_count: Int
    let icon: String
    let user: PostAuthor?
}

struct PostAuthor: Codable, Equatable {
    let name: String
    let photo_url_20: String
}

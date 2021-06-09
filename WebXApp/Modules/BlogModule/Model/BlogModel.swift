//
//  BlogModel.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 1/21/21.
//

import Foundation

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

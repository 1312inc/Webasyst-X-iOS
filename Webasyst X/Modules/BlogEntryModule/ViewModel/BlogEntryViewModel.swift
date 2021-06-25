//
//  BlogEntryViewModel.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 1/26/21.
//

import Foundation

protocol BlogEntryViewModelProtocol: AnyObject {
    var blogEntry: PostList { get }
    init(_ blogEntry: PostList)
    
}

class BlogEntryViewModel: BlogEntryViewModelProtocol {
    
    var blogEntry: PostList
    
    required init(_ blogEntry: PostList) {
        self.blogEntry = blogEntry
    }
    
}

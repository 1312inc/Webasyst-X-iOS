//
//  BlogEntryCoordinator.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 1/26/21.
//

import UIKit

protocol BlogEntryCoordinatorProtocol: class {
    var blogEntry: PostList { get }
    init(_ navigationController: UINavigationController, blogEntry: PostList)
}

class BlogEntryCoordinator: Coordinator, BlogEntryCoordinatorProtocol {
    
    var childCoordinator: [Coordinator] = []
    private var navigationController: UINavigationController
    var blogEntry: PostList
    
    required init(_ navigationController: UINavigationController, blogEntry: PostList) {
        self.navigationController = navigationController
        self.blogEntry = blogEntry
    }
    
    func start() {
        let blogEntryViewModel = BlogEntryViewModel(self.blogEntry)
        let blogEntryViewControler = BlogEntryViewController()
        blogEntryViewControler.viewModel = blogEntryViewModel
        self.navigationController.pushViewController(blogEntryViewControler, animated: true)
    }
    
}

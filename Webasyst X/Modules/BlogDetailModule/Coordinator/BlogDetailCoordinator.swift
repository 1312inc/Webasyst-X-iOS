//
//  BlogDetail module - BlogDetailCoordinator.swift
//  Webasyst-X-iOS
//
//  Created by viktkobst on 26/07/2021.
//  Copyright © 2021 1312 Inc.. All rights reserved.
//

import UIKit

//MARK BlogDetailCoordinator
final class BlogDetailCoordinator {
    
    var presenter: UINavigationController
    var screens: ScreensBuilder
    
    init(presenter: UINavigationController, screens: ScreensBuilder) {
        self.presenter = presenter
        self.screens = screens
    }
    
    func start(post: PostList) {
        self.initialViewController(post: post)
    }
    
    //MARK: Initial ViewController
    private func initialViewController(post: PostList) {
        let viewController = screens.createBlogDetailViewController(coordinator: self, post: post)
        presenter.pushViewController(viewController, animated: true)
    }
    
}

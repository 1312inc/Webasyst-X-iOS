//
//  BlogViewModule.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 1/18/21.
//

import Foundation
import RxSwift
import RxCocoa

protocol BlogViewModelProtocol {
    var dataSource: BehaviorRelay<[PostList]> { get }
    init(coordinator: BlogCoordinatorProtocol, blogNetworkingService: BlogNetworkingServiceProtocol)
    func fetchBlogPosts()
    func openInstallList()
    func openProfileScreen()
}

class BlogViewModel: BlogViewModelProtocol {
    
    private var coordinator: BlogCoordinatorProtocol
    private var blogNetworkingService: BlogNetworkingServiceProtocol
    
    var dataSource = BehaviorRelay(value: [PostList]())
    
    required init(coordinator: BlogCoordinatorProtocol, blogNetworkingService: BlogNetworkingServiceProtocol) {
        self.coordinator = coordinator
        self.blogNetworkingService = blogNetworkingService
    }
    
    func fetchBlogPosts() {
        _ = self.blogNetworkingService.getPosts().bind(onNext: { (posts) in
            self.dataSource.accept(posts)
        })
    }
    
    func openInstallList() {
        self.coordinator.openInstallList()
    }
    
    func openProfileScreen() {
        self.coordinator.openProfileScreen()
    }
    
}

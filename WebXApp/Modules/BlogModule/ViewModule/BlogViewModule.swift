//
//  BlogViewModule.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 1/18/21.
//

import Foundation
import RxSwift

protocol BlogViewModelProtocol {
    init(coordinator: BlogCoordinatorProtocol, blogNetworkingService: BlogNetworkingServiceProtocol)
    func fetchBlogPosts() -> Observable<[PostList]>
    func openInstallList()
    func openProfileScreen()
}

class BlogViewModel: BlogViewModelProtocol {
    
    private var coordinator: BlogCoordinatorProtocol
    private var blogNetworkingService: BlogNetworkingServiceProtocol
    
    required init(coordinator: BlogCoordinatorProtocol, blogNetworkingService: BlogNetworkingServiceProtocol) {
        self.coordinator = coordinator
        self.blogNetworkingService = blogNetworkingService
    }
    
    func fetchBlogPosts() -> Observable<[PostList]> {
        self.blogNetworkingService.getPosts().map {
            $0.map { $0 }
        }
    }
    
    func openInstallList() {
        self.coordinator.openInstallList()
    }
    
    func openProfileScreen() {
        self.coordinator.openProfileScreen()
    }
    
}

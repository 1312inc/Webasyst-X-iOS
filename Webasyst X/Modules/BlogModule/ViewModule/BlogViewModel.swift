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
    var blogPosts: [PostList] { get }
    var dataSource: BehaviorRelay<Result<[PostList]>> { get }
    init(coordinator: BlogCoordinatorProtocol, blogNetworkingService: BlogNetworkingServiceProtocol)
    func fetchBlogPosts()
    func openInstallList()
    func openBlogEntry(_ indexPath: Int)
    func changeUserDomain(_ domain: String) -> Bool
}

class BlogViewModel: BlogViewModelProtocol {
    
    private var coordinator: BlogCoordinatorProtocol
    private var blogNetworkingService: BlogNetworkingServiceProtocol
    
    var blogPosts = [PostList]()
    var dataSource = BehaviorRelay(value: Result<[PostList]>.Success([]))
    private var activeDomain = UserDefaults.standard.string(forKey: "selectDomainUser") ?? ""
    
    required init(coordinator: BlogCoordinatorProtocol, blogNetworkingService: BlogNetworkingServiceProtocol) {
        self.coordinator = coordinator
        self.blogNetworkingService = blogNetworkingService
    }

    // Retrieving installation blog entries
    func fetchBlogPosts() {
        _ = self.blogNetworkingService.getPosts().bind(onNext: { (result) in
            switch result {
            case .Success(let post):
                self.blogPosts = post
                self.dataSource.accept(Result.Success(post))
            case .Failure(let error):
                self.dataSource.accept(Result.Failure(error))
            }
        })
    }
    
    // Opening the install list
    func openInstallList() {
        self.coordinator.openInstallList()
    }
    
    //Opening detail blog entry
    func openBlogEntry(_ indexPath: Int) {
        self.coordinator.openDetailBlogEntry(self.blogPosts[indexPath])
    }
    
    func changeUserDomain(_ domain: String) -> Bool {
        guard domain == self.activeDomain else {
            self.activeDomain = domain
            return false
        }
        self.activeDomain = domain
        return true
    }
    
}

//
//  BlogViewModule.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 1/18/21.
//

import Foundation
import RxSwift
import RxCocoa
import Moya

protocol BlogViewModelProtocol {
    var isLoadingSubject: BehaviorSubject<Bool> { get }
    var errorRequestSubject: PublishSubject<ServerError> { get }
    var blogListSubject: BehaviorSubject<[PostList]> { get }
    init(moyaProvider: MoyaProvider<NetworkingService>)
    func changeUserDomain(_ domain: String)
}

class BlogViewModel: BlogViewModelProtocol {
    
    var isLoadingSubject = BehaviorSubject<Bool>(value: true)
    var errorRequestSubject = PublishSubject<ServerError>()
    var blogListSubject = BehaviorSubject<[PostList]>(value: [])
    
    private var activeDomain = UserDefaults.standard.string(forKey: "selectDomainUser") ?? ""
    private var moyaProvider: MoyaProvider<NetworkingService>
    private let disposeBag = DisposeBag()
    
    required init(moyaProvider: MoyaProvider<NetworkingService>) {
        self.moyaProvider = moyaProvider
        self.fetchBlogPosts()
    }
    
    // Retrieving installation blog entries
    func fetchBlogPosts() {
        isLoadingSubject.onNext(true)
        moyaProvider.rx.request(.requestBlogList)
            .subscribe { response in
                guard let statusCode = response.response?.statusCode else {
                    self.isLoadingSubject.onNext(false)
                    self.errorRequestSubject.onNext(.requestFailed(text: "Failed to get server reply status code"))
                    return
                }
                switch statusCode {
                case 200...299:
                    do {
                        let postData = try JSONDecoder().decode(PostsBlog.self, from: response.data)
                        if let posts = postData.posts {
                            if !posts.isEmpty {
                                self.isLoadingSubject.onNext(false)
                                self.blogListSubject.onNext(posts)
                            } else {
                                self.isLoadingSubject.onNext(false)
                                self.errorRequestSubject.onNext(.notEntity)
                            }
                        } else {
                            self.isLoadingSubject.onNext(false)
                            self.errorRequestSubject.onNext(.notEntity)
                        }
                    } catch let error {
                        self.isLoadingSubject.onNext(false)
                        self.errorRequestSubject.onNext(.requestFailed(text: error.localizedDescription))
                    }
                case 401:
                    self.isLoadingSubject.onNext(false)
                    self.errorRequestSubject.onNext(.permisionDenied)
                case 400:
                    self.isLoadingSubject.onNext(false)
                    self.errorRequestSubject.onNext(.notInstall)
                default:
                    self.isLoadingSubject.onNext(false)
                    self.errorRequestSubject.onNext(.permisionDenied)
                }
            } onError: { error in
                self.isLoadingSubject.onNext(false)
                self.errorRequestSubject.onNext(.requestFailed(text: error.localizedDescription))
            }.disposed(by: disposeBag)
    }
    
    func changeUserDomain(_ domain: String) {
        if domain != self.activeDomain {
            self.activeDomain = domain
            self.fetchBlogPosts()
        }
    }
    
}

//
//  UserNetworkingService.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 1/20/21.
//

import Foundation
import Alamofire
import RxSwift



protocol BlogNetworkingServiceProtocol {
    func getPosts() -> Observable<Result<[PostList]>>
}

class BlogNetworkingService: UserNetworkingManager, BlogNetworkingServiceProtocol {
    
    private let profileInstallListService = ProfileInstallListService()
    
    func getPosts() -> Observable<Result<[PostList]>> {
        return Observable.create { (observer) -> Disposable in
            
            let selectDomain = UserDefaults.standard.string(forKey: "selectDomainUser") ?? ""
            
            let parameters: [String: String] = [
                "hash": "author/0",
                "limit": "10",
                "access_token": self.profileInstallListService.getTokenActiveInstall(selectDomain)
            ]
            
            AF.request(self.buildApiUrl(path: "/api.php/blog.post.search", parameters: parameters)!, method: .get).response { response in
                switch response.result {
                case .success:
                    guard let statusCode = response.response?.statusCode else {
                        observer.onNext(Result.Failure(.requestFailed))
                        return
                    }
                    switch statusCode {
                    case 200...299:
                        if let data = response.data {
                            let blog = try! JSONDecoder().decode(PostsBlog.self, from: data)
                            if blog.posts.isEmpty {
                                observer.onNext(Result.Failure(.notEntity))
                            } else {
                                observer.onNext(Result.Success(blog.posts))
                            }
                            observer.onCompleted()
                        }
                    case 401:
                        observer.onNext(Result.Failure(.permisionDenied))
                        observer.onCompleted()
                    default:
                        observer.onNext(Result.Failure(.permisionDenied))
                        observer.onCompleted()
                    }
                case .failure:
                    observer.onNext(Result.Failure(.requestFailed))
                    observer.onCompleted()
                }
            }
            
            return Disposables.create {
                observer.onNext(Result.Failure(.requestFailed))
            }
        }
        
    }
    
}

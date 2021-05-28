//
//  UserNetworkingService.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 1/20/21.
//

import Foundation
import Alamofire
import RxSwift
import Webasyst

protocol BlogNetworkingServiceProtocol {
    func getPosts() -> Observable<Result<[PostList]>>
}

class BlogNetworkingService: UserNetworkingManager, BlogNetworkingServiceProtocol {
    
    private let webasyst = WebasystApp()
    
    func getPosts() -> Observable<Result<[PostList]>> {
        return Observable.create { [self] (observer) -> Disposable in
            
            let selectDomain = UserDefaults.standard.string(forKey: "selectDomainUser") ?? ""
            
            guard let changeInstall = webasyst.getUserInstall(selectDomain) else {
                observer.onCompleted()
                return Disposables.create { }
            }
 
            let parameters: Parameters = [
                "hash": "author/0",
                "limit": "10",
                "access_token": "\(String(describing: changeInstall.accessToken))"
            ]
            
            let url = changeInstall.url
            
            let request = AF.request("\(url)/api.php/blog.post.search", method: .get, parameters: parameters, encoding: URLEncoding(destination: .queryString)).response { response in
                switch response.result {
                case .success:
                    guard let statusCode = response.response?.statusCode else {
                        observer.onNext(Result.Failure(.requestFailed(text: NSLocalizedString("getStatusCodeError", comment: ""))))
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
                    case 400:
                        observer.onNext(Result.Failure(.notInstall))
                        observer.onCompleted()
                    default:
                        observer.onNext(Result.Failure(.permisionDenied))
                        observer.onCompleted()
                    }
                case .failure:
                    observer.onNext(Result.Failure(.requestFailed(text: NSLocalizedString("getStatusCodeError", comment: ""))))
                    observer.onCompleted()
                }
            }
            
            request.resume()
            
            return Disposables.create {
                request.cancel()
            }
        }
        
    }
    
}

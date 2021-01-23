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
    func getPosts() -> Observable<[PostList]>
}

class BlogNetworkingService: UserNetworkingManager, BlogNetworkingServiceProtocol {
    
    private let profileInstallListService = ProfileInstallListService()
    
    func getPosts() -> Observable<[PostList]> {
        return Observable<[PostList]>.create { (observer) -> Disposable in
            
            let parameters: [String: String] = [
                "hash": "author/0",
                "limit": "10",
                "access_token": self.profileInstallListService.getTokenActiveInstall(UserDefaults.standard.string(forKey: "selectDomainUser") ?? "")
            ]
            
            print(parameters)
            
            let request = AF.request(self.buildApiUrl(path: "/api.php/blog.post.search", parameters: parameters)!, method: .get).response { response in
                switch response.result {
                case .success:
                    guard let statusCode = response.response?.statusCode else {
                        observer.onError(NSError(domain: "STATUS_CODE_FAILURE", code: 404, userInfo: nil))
                        return
                    }
                    switch statusCode {
                    case 200...299:
                        if let data = response.data {
                            let blog = try! JSONDecoder().decode(PostsBlog.self, from: data)
                            observer.onNext(blog.posts)
                            observer.onCompleted()
                        }
                    case 401:
                        observer.onError(NSError(domain: "PERMISSION_DENIED", code: 401, userInfo: nil))
                    default:
                        let text = try! JSONSerialization.jsonObject(with: response.data!, options: []) as! [String: Any]
                        print(text)
                        observer.onError(NSError(domain: "RESPONSE_ERROR", code: response.response?.statusCode ?? -1, userInfo: nil))
                    }
                case .failure:
                    observer.onError(NSError(domain: "REQUEST_FAILER", code: 404, userInfo: nil))
                }
            }
            
            request.resume()
            
            return Disposables.create {
                request.cancel()
            }
        }
        
    }
    
}

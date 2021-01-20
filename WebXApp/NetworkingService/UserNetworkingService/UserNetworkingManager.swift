//
//  UserNetworkingManager.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 1/20/21.
//

import Foundation
import RxSwift
import Alamofire

protocol UserNetworkingManagerProtocol {
    
    func buildApiUrl(path: String, parameters: [String: String]) -> Observable<URL>
    func downloadImage(_ imagePath: String, completion: @escaping (Data) -> ())
}

class UserNetworkingManager: UserNetworkingManagerProtocol {
    
    
    func buildApiUrl(path: String, parameters: [String : String]) -> Observable<URL> {
        
        return Observable.create { observer -> Disposable in
            guard let domainApi = UserDefaults.standard.string(forKey: "selectDomainUser") else {
                observer.onError(NSError(domain: "build ApiUrl domain api error", code: -1, userInfo: nil))
                return Disposables.create { }
            }
            var urlComponents: URL? {
                var components = URLComponents()
                components.scheme = "https"
                components.host = domainApi
                components.path = path
                if !parameters.isEmpty {
                    var queryParams = [URLQueryItem]()
                    for (value, key) in parameters {
                        queryParams.append(URLQueryItem(name: key, value: value))
                    }
                    components.queryItems = queryParams
                }
                return components.url
            }
            if let url = urlComponents?.absoluteURL {
                observer.onNext(url)
                observer.onCompleted()
                return Disposables.create { }
            } else {
                observer.onError(NSError(domain: "buildApiUrl user domain url nil", code: -1, userInfo: nil))
                return Disposables.create { }
            }
        }.asObservable()
        
    }
    
    private func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func downloadImage(_ imagePath: String, completion: @escaping (Data) -> ()) {
        getData(from: URL(string: imagePath)!) { data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async() {
                completion(data)
            }
        }
    }
}

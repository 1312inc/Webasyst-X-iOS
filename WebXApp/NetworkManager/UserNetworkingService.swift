//
//  UserNetworkingService.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 1/18/21.
//

import Foundation
import Alamofire
import RxSwift

protocol UserNetworkingServiceProtocol {
    func getUserData(completion: @escaping (Bool) -> ())
    func getInstallList() -> Observable<[InstallList]>
}

final class UserNetworkingService: NetworkingManager, UserNetworkingServiceProtocol {
    
    //MARK: Get user data
    public func getUserData(completion: @escaping (Bool) -> ()) {
        
        let accessToken = KeychainManager.load(key: "accessToken")
        let accessTokenString = String(decoding: accessToken ?? Data("".utf8), as: UTF8.self)
        
        let headers: HTTPHeaders = [
            "Authorization": accessTokenString
        ]
        
        AF.request(buildWebasystUrl("/id/api/v1/profile/", parameters: [:]), method: .get, headers: headers).response { (response) in
            switch response.result {
            case .success:
                guard let statusCode = response.response?.statusCode else { return }
                switch statusCode {
                case 200...299:
                    let userData = try! JSONDecoder().decode(UserData.self, from: response.data!)
                    let userDefaults = UserDefaults.standard
                    userDefaults.set(userData.name, forKey: "userName")
                    userDefaults.set(userData.email[0].value, forKey: "userEmail")
                    completion(true)
                default:
                    completion(false)
                }
            case .failure:
                print("Get user data failure")
            }
        }
    }
    
    //MARK: Get installation's list user
    public func getInstallList() -> Observable<[InstallList]> {
        
        return Observable.create { observer -> Disposable in
            
            let accessToken = KeychainManager.load(key: "accessToken")
            let accessTokenString = String(decoding: accessToken ?? Data("".utf8), as: UTF8.self)
            
            let headers: HTTPHeaders = [
                "Authorization": accessTokenString
            ]
            
             let request = AF.request(self.buildWebasystUrl("/id/api/v1/installations/", parameters: [:]), method: .get, headers: headers).response { (response) in
                switch response.result {
                case .success:
                    guard let statusCode = response.response?.statusCode else { return }
                    switch statusCode {
                    case 200...299:
                        if let data = response.data {
                            let installList = try! JSONDecoder().decode([InstallList].self, from: data)
                            observer.onNext(installList)
                            observer.onCompleted()
                        }
                    default:
                        observer.onError(NSError(domain: "UserNetworkingService server answer code not 200", code: -1, userInfo: nil))
                    }
                case .failure:
                    observer.onError(NSError(domain: "UserNetworkingService failure", code: -1, userInfo: nil))
                }
            }
            
            request.resume()
            
            return Disposables.create {
                request.cancel()
            }
            
        }
        
    }
}

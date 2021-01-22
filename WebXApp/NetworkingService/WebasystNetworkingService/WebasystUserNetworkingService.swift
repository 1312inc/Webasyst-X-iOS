//
//  UserNetworkingService.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 1/18/21.
//

import Foundation
import Alamofire
import RxSwift

protocol WebasystUserNetworkingServiceProtocol {
    func getUserData()
    func refreshAccessToken()
    func preloadUserData() -> Observable<(String, Int)>
}

final class WebasystUserNetworkingService: WebasystNetworkingManager, WebasystUserNetworkingServiceProtocol {
    
    private var timer: DispatchSourceTimer?
    private let bundleId: String = Bundle.main.bundleIdentifier ?? ""
    private let profileInstallService = ProfileInstallListService()
    private let queue = DispatchQueue(label: "WebasystUserNetworkingService")
    private let semaphore = DispatchSemaphore(value: 2)
    
    func preloadUserData() -> Observable<(String, Int)> {
        return Observable.create { (observer) -> Disposable in
            self.getInstallList { (installList) in
                observer.onNext(("Заправляем топливо", 30))
                var clientId: [String] = []
                for install in installList {
                    clientId.append(install.id)
                }
                self.getAccessTokenApi(clientID: clientId) { (accessToken) in
                    observer.onNext(("Готовимся на старт", 30))
                    self.getAccessTokenInstall(installList, accessCodes: accessToken) { (saveSuccess) in
                        self.queue.async {
                            observer.onNext(("Поехали!", 30))
                            self.semaphore.signal()
                        }
                        self.semaphore.wait()
                        self.queue.async {
                            observer.onCompleted()
                        }
                    }
                    
                }
                
            }
            
            return Disposables.create {  }
        }
    }
    
    //MARK: Get user data
    public func getUserData() {
        
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
                    UserDefaults.standard.setValue(userData.firstname, forKey: "userName")
                    UserNetworkingManager().downloadImage(userData.userpic_original_crop) { data in
                        ProfileDataService().saveProfileData(userData, avatar: data)
                    }
                default:
                    print("get user data not 200 response")
                }
            case .failure:
                print("get user data request failure")
            }
        }
    }
    
    //MARK: Get installation's list user
    public func getInstallList(completion: @escaping ([InstallList]) -> ()) {
        
        let accessToken = KeychainManager.load(key: "accessToken")
        let accessTokenString = String(decoding: accessToken ?? Data("".utf8), as: UTF8.self)
        
        let headers: HTTPHeaders = [
            "Authorization": accessTokenString
        ]
        
        AF.request(self.buildWebasystUrl("/id/api/v1/installations/", parameters: [:]), method: .get, headers: headers).response { (response) in
            switch response.result {
            case .success:
                guard let statusCode = response.response?.statusCode else { return }
                switch statusCode {
                case 200...299:
                    if let data = response.data {
                        let installList = try! JSONDecoder().decode([InstallList].self, from: data)
                        if UserDefaults.standard.string(forKey: "selectDomainUser") == nil {
                            UserDefaults.standard.setValue(installList[0].domain, forKey: "selectDomainUser")
                        }
                        completion(installList)
                    }
                default:
                    print("UserNetworkingService server answer code not 200")
                }
            case .failure:
                print("UserNetworkingService failure")
            }
        }
        
    }
    
    func refreshAccessToken() {
        
        let refreshToken = KeychainManager.load(key: "refreshToken")
        let refreshTokenString = String(decoding: refreshToken ?? Data("".utf8), as: UTF8.self)
        
        let paramsRequest: [String: String] = [
            "grant_type": "refresh_token",
            "refresh_token": refreshTokenString,
            "client_id": clientId
        ]
        
        AF.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in paramsRequest {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: key)
            }
        }, to: buildWebasystUrl("/id/oauth2/auth/token", parameters: [:]), method: .post).response { (response) in
            switch response.result {
            case .success:
                guard let statusCode = response.response?.statusCode else { return }
                switch statusCode {
                case 200...299:
                    if let data = response.data {
                        let authData = try! JSONDecoder().decode(UserToken.self, from: data)
                        let _ = KeychainManager.save(key: "accessToken", data: Data("Bearer \(authData.access_token)".utf8))
                        let _ = KeychainManager.save(key: "refreshToken", data: Data(authData.refresh_token.utf8))
                    }
                default:
                    print("Token refresh error answer")
                }
            case .failure:
                print("Refresh token failure request")
            }
        }
    }
    
    func getAccessTokenApi(clientID: [String], completion: @escaping ([String: Any]) -> ()) {
        
        let paramReqestApi: Parameters = [
            "client_id": clientID
        ]
        
        let accessToken = KeychainManager.load(key: "accessToken")
        let accessTokenString = String(decoding: accessToken ?? Data("".utf8), as: UTF8.self)
        
        let headerRequest: HTTPHeaders = [
            "Authorization": accessTokenString
        ]
        
        AF.request(self.buildWebasystUrl("/id/api/v1/auth/client/", parameters: [:]), method: .post, parameters: paramReqestApi, headers: headerRequest).response { (response) in
            switch response.result {
            case .success:
                if let statusCode = response.response?.statusCode {
                    switch statusCode {
                    case 200...299:
                        if let data = response.data {
                            let accessTokens = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                            completion(accessTokens)
                        }
                    default:
                        print("getAccessTokenApi status code request \(statusCode)")
                    }
                } else {
                    print("getAccessTokenApi status code error")
                }
            case .failure:
                print("get center Api tokens list error request")
            }
        }
        
    }
    
    
    func getAccessTokenInstall(_ installList: [InstallList], accessCodes: [String: Any], completion: @escaping (Bool) -> ()) {
        for install in installList {
            let code = accessCodes.filter { $0.key == install.id }.first?.value ?? ""
            self.semaphore.wait()
            self.queue.async {
                AF.upload(multipartFormData: { (multipartFormData) in
                    multipartFormData.append("\(String(describing: code))".data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: "code")
                    multipartFormData.append("blog,site,shop".data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: "scope")
                    multipartFormData.append(self.bundleId.data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: "client_id")
                }, to: "\(install.url)/api.php/token-headless", method: .post).response {response in
                    switch response.result {
                    case .success:
                        if let statusCode = response.response?.statusCode {
                            switch statusCode {
                            case 200...299:
                                if let data = response.data {
                                    let accessCode = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                                    self.profileInstallService.saveInstall(install, accessToken: "\(accessCode.first?.value ?? "")")
                                    completion(true)
                                    self.semaphore.signal()
                                }
                            default:
                                print("getAccessTokenInstall status code \(statusCode)")
                            }
                        }
                    case .failure:
                        print("error getAccessTokenInstall request")
                    }
                }
            }
        }
    }
    
}

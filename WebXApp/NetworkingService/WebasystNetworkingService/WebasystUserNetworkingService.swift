//
//  UserNetworkingService.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 1/18/21.
//

import Foundation
import Alamofire
import RxSwift
import RxCocoa

protocol WebasystUserNetworkingServiceProtocol {
    func getUserData()
    func refreshAccessToken()
    func preloadUserData() -> Observable<(String, Int, Bool)>
}

final class WebasystUserNetworkingService: WebasystNetworkingManager, WebasystUserNetworkingServiceProtocol {
    
    private let bundleId: String = Bundle.main.bundleIdentifier ?? ""
    private let profileInstallService = ProfileInstallListService()
    private let networkingHelper = NetworkingHelper()
    private let queue = DispatchQueue(label: "com.webasyst.x.ios.WebasystUserNetworkingService", qos: .userInitiated)
    private let dispatchGroup = DispatchGroup()
    private let disposeBag = DisposeBag()
    
    func preloadUserData() -> Observable<(String, Int, Bool)> {
        return Observable.create { (observer) -> Disposable in
            if self.networkingHelper.isConnectedToNetwork() {
                self.queue.async(group: self.dispatchGroup) {
                    self.refreshAccessToken()
                }
                self.queue.async {
                    self.getUserData()
                }
                self.dispatchGroup.notify(queue: self.queue) {
                    self.getInstallList { (successGetInstall, installList) in
                        if successGetInstall {
                            observer.onNext((NSLocalizedString("refuelingMessage", comment: ""), 30, true))
                            var clientId: [String] = []
                            for install in installList {
                                clientId.append(install.id)
                            }
                            self.getAccessTokenApi(clientID: clientId) { (success, accessToken) in
                                if success {
                                    observer.onNext((NSLocalizedString("gettingReadyMessage", comment: ""), 30, true))
                                    self.getAccessTokenInstall(installList, accessCodes: accessToken) { (loadText, saveSuccess) in
                                        if !saveSuccess {
                                            observer.onNext((loadText, 30, true))
                                        } else {
                                            observer.onCompleted()
                                        }
                                    }
                                } else {
                                    observer.onNext((NSLocalizedString("loadingError", comment: ""), 30, true))
                                    observer.onError(NSError(domain: "getAccessTokenApi error", code: 401, userInfo: nil))
                                }
                            }
                        } else {
                            observer.onNext((NSLocalizedString("loadingError", comment: ""), 30, true))
                            observer.onError(NSError(domain: "getInstallList error", code: 401, userInfo: nil))
                        }
                    }
                }
            } else {
                observer.onNext((NSLocalizedString("connectionAlertMessage", comment: ""), 0, false))
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
                    print("getUserData not 200 response")
                }
            case .failure:
                print("getUserData request failure")
            }
        }
    }
    
    //MARK: Get installation's list user
    public func getInstallList(completion: @escaping (Bool, [InstallList]) -> ()) {
        
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
                        completion(true, installList)
                    }
                default:
                    print("getInstallList server answer code not 200")
                    completion(false, [])
                }
            case .failure:
                print("getInstallList failure")
                completion(false, [])
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
        self.dispatchGroup.enter()
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
                        self.dispatchGroup.leave()
                    }
                default:
                    print("refreshAccessToken error answer \(statusCode)")
                    self.dispatchGroup.leave()
                }
            case .failure:
                print("refreshAccessToken failure request")
            }
        }
    }
    
    func getAccessTokenApi(clientID: [String], completion: @escaping (Bool, [String: Any]) -> ()) {
        
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
                            completion(true, accessTokens)
                        }
                    default:
                        print("getAccessTokenApi status code request \(statusCode)")
                        completion(false, [:])
                    }
                } else {
                    print("getAccessTokenApi status code error")
                    completion(false, [:])
                }
            case .failure:
                print("get center Api tokens list error request")
                completion(false, [:])
            }
        }
    }
    
    func getAccessTokenInstall(_ installList: [InstallList], accessCodes: [String: Any], completion: @escaping (String, Bool) -> ()) {
        self.queue.async(group: dispatchGroup) {
            for install in installList {
                let code = accessCodes[install.id] ?? ""
                self.dispatchGroup.enter()
                AF.upload(multipartFormData: { (multipartFormData) in
                    multipartFormData.append("\(String(describing: code))".data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: "code")
                    multipartFormData.append("blog,site,shop,webasyst".data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: "scope")
                    multipartFormData.append(self.bundleId.data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: "client_id")
                }, to: "\(install.url)/api.php/token-headless", method: .post).response {response in
                    switch response.result {
                    case .success:
                        if let statusCode = response.response?.statusCode {
                            switch statusCode {
                            case 200...299:
                                if let data = response.data {
                                    let accessTokenInstall = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                                    self.profileInstallService.saveInstall(install, accessToken: "\(accessTokenInstall.first?.value ?? "")")
                                    defer {
                                        self.dispatchGroup.leave()
                                    }
                                    completion("\(NSLocalizedString("loadingInstallMessage", comment: "")) \(install.domain)", false)
                                }
                            default:
                                self.profileInstallService.saveInstall(install, accessToken: "")
                                defer {
                                    self.dispatchGroup.leave()
                                }
                                completion("\(NSLocalizedString("errorInstallMessage", comment: "")) \(install.domain)", false)
                            }
                        }
                    case .failure:
                        defer {
                            self.dispatchGroup.leave()
                        }
                        completion("\(NSLocalizedString("errorInstallMessage", comment: "")) \(install.domain)", false)
                    }
                }
            }
        }
        self.dispatchGroup.notify(queue: queue) {
            completion(NSLocalizedString("deleteInstallMessage", comment: ""), false)
            self.deleteNonActiveInstall(installList) { text, bool in
                completion("", true)
            }
        }
    }
    
    func deleteNonActiveInstall(_ installList: [InstallList], completion: @escaping (String, Bool)->()) {
        var saveInstallList = [ProfileInstallList]()
        
        DispatchQueue.main.async {
            self.profileInstallService.getInstallList()
                .bind { (result) in
                    switch result {
                    case .Success(let install):
                        saveInstallList = install
                    case .Failure(_):
                        saveInstallList = []
                    }
                }.disposed(by: self.disposeBag)
            
            for install in saveInstallList {
                let find = installList.filter({ $0.id == install.clientId ?? "" })
                if find.isEmpty {
                    self.profileInstallService.deleteInstall(clientId: install.clientId ?? "")
                }
            }
            completion("", true)
        }
    }
    
    func singUpUser(completion: @escaping (Bool) -> ()) {
        
        let accessToken = KeychainManager.load(key: "accessToken")
        let accessTokenString = String(decoding: accessToken ?? Data("".utf8), as: UTF8.self)
        
        let headerRequest: HTTPHeaders = [
            "Authorization": accessTokenString
        ]
        
        AF.request(self.buildWebasystUrl("/id/api/v1/delete/", parameters: [:]), method: .delete, headers: headerRequest).response { (response) in
            switch response.result {
            case .success:
                if let statusCode = response.response?.statusCode {
                    switch statusCode {
                    case 200...299:
                        completion(true)
                    default:
                        print("singUpUser status code request \(statusCode)")
                        completion(false)
                    }
                } else {
                    print("singUpUser status code error")
                    completion(false)
                }
            case .failure:
                print("singUpUser error request")
                completion(false)
            }
        }
    }
    
}

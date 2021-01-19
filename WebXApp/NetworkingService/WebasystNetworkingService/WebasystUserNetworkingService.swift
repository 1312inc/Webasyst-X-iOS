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
    func getUserData(completion: @escaping (Bool) -> ())
    func getInstallList() -> Observable<[InstallList]>
    func refreshAccessToken()
}

final class WebasystUserNetworkingService: WebasystNetworkingManager, WebasystUserNetworkingServiceProtocol {
    
    private var timer: DispatchSourceTimer?
    
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
                            UserDefaults.standard.setValue(installList[0].domain, forKey: "selectDomainUser")
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
                        self.startRefreshTokenTimer(timeInterval: authData.expires_in)
                        }
                default:
                    print("Token refresh error answer")
                }
            case .failure:
                print("Refresh token failure request")
            }
        }
    }
    
    private func startRefreshTokenTimer(timeInterval: Int) {
        let queue = DispatchQueue(label: "com.domain.app.timerRefreshAccessToken")
        timer = DispatchSource.makeTimerSource(queue: queue)
        timer!.schedule(deadline: .now(), repeating: .seconds(timeInterval))
        timer!.setEventHandler { [weak self] in
            self?.refreshAccessToken()
        }
        timer!.resume()
    }

    private func stopTimer() {
        timer?.cancel()
        timer = nil
    }
    
}

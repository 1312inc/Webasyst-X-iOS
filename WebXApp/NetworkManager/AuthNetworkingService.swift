//
//  AuthNetworkingService.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 1/14/21.
//

import Foundation
import CryptoKit
import Alamofire

struct UserToken: Codable {
    let access_token: String
    let token_type: String
    let expires_in: Int
    let refresh_token: String
}

struct UserData: Codable {
    let name: String
    let email: [Email]
    let userpic: String
}

struct Email: Codable {
    let value: String
}

private protocol AuthNetworkingServicePrivateProtocol: class {
    func buildAuthUrl(_ path: String, parameters: [String: String]) -> URL
    func generatePasswordHash(_ len: Int) -> String
}

public protocol AuthNetworkingServicePublicProtocol: class {
    func buildAuthRequest() -> URLRequest
    func getAccessToken(_ authCode: String, stateString: String, completion: @escaping (Bool) -> Void)
    func getUserData(completion: @escaping (Bool) -> ())
}

class AuthNetworkingService: NetworkingManager, AuthNetworkingServicePrivateProtocol, AuthNetworkingServicePublicProtocol {
    
    private let bundleId: String = Bundle.main.bundleIdentifier ?? ""
    private let stateString: String = Bundle.main.bundleIdentifier ?? ""
    private var disposablePasswordAuth: String? = nil
    
    //MARK: Build URL Webasyst Auth
    fileprivate func buildAuthUrl(_ path: String, parameters: [String: String]) -> URL {
        var urlComponents: URL? {
            var component = URLComponents()
            component.scheme = "https"
            component.host = host
            component.path = path
            if !parameters.isEmpty {
                var queryParams = [URLQueryItem]()
                for param in parameters {
                    queryParams.append(URLQueryItem(name: param.key, value: param.value))
                }
                component.queryItems = queryParams
            }
            return component.url
        }
        return urlComponents!.absoluteURL
    }
    
    //MARK: Generating a one-time password in Webasyst
    fileprivate func generatePasswordHash(_ len: Int) -> String {
        let pswdChars = Array("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890")
        let rndPswd = String((0..<len).map{ _ in pswdChars[Int(arc4random_uniform(UInt32(pswdChars.count)))]})
        self.disposablePasswordAuth = rndPswd
        let inputData = Data((rndPswd.utf8))
        let hashedPassword = SHA256.hash(data: inputData)
        print(Data(hashedPassword.description.utf8).base64EncodedString())
        return rndPswd
    }
    
    //MARK: Build URLRequset in Webasyst Auth
    public func buildAuthRequest() -> URLRequest {
        
        let paramRequest: [String: String] = [
            "response_type": "code",
            "client_id": clientId,
            "scope": "token:blog.site.shop",
            "redirect_uri": "\(bundleId)://oidc_callback",
            "state": bundleId,
            "code_challenge": self.generatePasswordHash(64),
            "code_challenge_method": "plain"
        ]
        
        var request = URLRequest(url: buildAuthUrl("/id/oauth2/auth/code", parameters: paramRequest))
        request.httpMethod = "GET"
        return request
    }
    
    //MARK: Obtaining a permanent token Webasyst
    public func getAccessToken(_ authCode: String, stateString: String, completion: @escaping (Bool) -> Void) {
        
        guard let disposablePassword = self.disposablePasswordAuth else { return }
        guard stateString == self.stateString else { return }
        
        let headers: HTTPHeaders = [
            "Content-type": "multipart/form-data"
        ]
        
        let paramRequest: [String: String] = [
            "grant_type": "authorization_code",
            "code": authCode,
            "redirect_uri": "\(bundleId)://oidc_callback",
            "client_id": clientId,
            "code_verifier": disposablePassword
        ]
        
        AF.upload(multipartFormData: { multipartFormData in
            for (key, value) in paramRequest {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: key)
            }
        }, to: buildAuthUrl("/id/oauth2/auth/token", parameters: [:]), usingThreshold: UInt64.init(), method: .post, headers: headers).responseJSON(completionHandler: { (response) in
            switch response.result {
            case .success:
                guard let statusCode = response.response?.statusCode else {
                    completion(false)
                    return
                }
                switch statusCode {
                case 200...299:
                    if let data = response.data {
                        let authData = try! JSONDecoder().decode(UserToken.self, from: data)
                        let accessTokenSuccess = KeychainManager.save(key: "accessToken", data: Data("Bearer \(authData.access_token)".utf8))
                        let refreshTokenSuccess = KeychainManager.save(key: "refreshToken", data: Data(authData.refresh_token.utf8))
                        if accessTokenSuccess == 0 && refreshTokenSuccess == 0 {
                            completion(true)
                        }
                    }
                default:
                    let outputStr  = String(data: response.data!, encoding: String.Encoding.utf8)
                    print(outputStr ?? "")
                    completion(false)
                }
            case .failure:
                completion(false)
            }
        })
        
    }
    
    //MARK: Get user data
    public func getUserData(completion: @escaping (Bool) -> ()) {
        
        let accessToken = KeychainManager.load(key: "accessToken")
        let accessTokenString = String(decoding: accessToken ?? Data("".utf8), as: UTF8.self)
        
        let headers: HTTPHeaders = [
            "Authorization": accessTokenString
        ]
        
        AF.request(buildAuthUrl("/id/api/v1/profile/", parameters: [:]), method: .get, headers: headers).response { (response) in
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
                print("failure")
            }
        }
    }
    
}

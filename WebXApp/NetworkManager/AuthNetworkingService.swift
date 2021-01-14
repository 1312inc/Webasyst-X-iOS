//
//  AuthNetworkingService.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 1/14/21.
//

import Foundation
import CryptoKit

private protocol AuthNetworkingServicePrivateProtocol: class {
    func buildAuthUrl(_ path: String, parameters: [String: String]) -> URL
    func generatePasswordHash(_ len: Int) -> String
}

public protocol AuthNetworkingServicePublicProtocol: class {
    func buildAuthRequest() -> URLRequest
    func getAccessToken(_ authCode: String, stateString: String)
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
            var queryParams = [URLQueryItem]()
            for param in parameters {
                queryParams.append(URLQueryItem(name: param.key, value: param.value))
            }
            component.queryItems = queryParams
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
        return hashedPassword.description
    }
    
    //MARK: Build URLRequset in Webasyst Auth
    public func buildAuthRequest() -> URLRequest {
        
        let paramRequest: [String: String] = [
            "response_type": "code",
            "client_id": clientId,
            "scope": "token:blog.site.shop",
            "redirect_uri": "\(bundleId)://oidc_callback",
            "state": "test_string",
            "code_challenge": self.generatePasswordHash(64),
            "code_challenge_method": "SHA256"
        ]
        
        var request = URLRequest(url: buildAuthUrl("/id/oauth2/auth/code", parameters: paramRequest))
        request.httpMethod = "GET"
        return request
    }
    
    //MARK: Obtaining a permanent token Webasyst
    public func getAccessToken(_ authCode: String, stateString: String) {
        
        guard let disposablePassword = self.disposablePasswordAuth else { return }
        
        let paramRequest: [String: String] = [
            "grant_type": "authorization_code",
            "code": authCode,
            "redirect_uri": bundleId,
            "client_id": clientId,
            "code_verifier": disposablePassword
        ]
        
        var request = URLRequest(url: buildAuthUrl("/id/oauth2/auth/token", parameters: paramRequest))
        request.httpMethod = "POST"
        
        DispatchQueue.global(qos: .utility).async {
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                do {
                    
                } catch {
                    
                }
            }
        }
    }
    
}

//
//  AddAccountNetworking.swift
//  Shop-Script
//
//  Created by Леонид Лукашевич on 07.02.2023.
//

import Foundation
import Webasyst

internal class AddAccountNetworking {
    
    public static let shared = AddAccountNetworking()
    private init() {}
    
    func connectWebasystAccount(withDigitalCode code: String, completion: @escaping (Bool, String?, String?) -> ()) {
        
        let accessToken = UserDefaults.standard.data(forKey: "accessToken")
        let accessTokenString = String(decoding: accessToken ?? Data("".utf8), as: UTF8.self)
        
        let headers: Parameters = [
            "Authorization": accessTokenString
        ]
        
        let parametersRequest: Parameters = [
            "code": code
        ]
        
        guard let url = URL(string: "https://www.webasyst.com/id/api/v1/installation/connect/") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        for (key, value) in headers {
            request.addValue(value, forHTTPHeaderField: key)
        }
        
        if let encodedData = try? JSONSerialization.data(withJSONObject: parametersRequest, options: .fragmentsAllowed) {
            request.httpBody = encodedData
        }
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            guard error == nil, let data = data else {
                print(NSError(domain: "Webasyst error: \(String(describing: error?.localizedDescription))", code: 401, userInfo: nil))
                completion(false, nil, nil)
                return
            }
            
            do {
                if let dictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] {
                    if let id = dictionary["id"] as? String,
                       let url = dictionary["url"] as? String {
                        completion(true, id, url)
                    } else if let error = dictionary["error_description"] as? String {
                        completion(false, nil, error)
                    }
                }
            } catch {
                if let dictionary = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any],
                   let error = dictionary["error"] as? String {
                    completion(false, nil, error)
                } else {
                    completion(false, nil, nil)
                }
            }
            
        }.resume()
    }
}

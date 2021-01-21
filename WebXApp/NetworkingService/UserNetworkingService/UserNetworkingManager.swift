//
//  UserNetworkingManager.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 1/20/21.
//

import Foundation

protocol UserNetworkingManagerProtocol {
    
    func buildApiUrl(path: String, parameters: [String: String]) -> URL?
    func downloadImage(_ imagePath: String, completion: @escaping (Data) -> ())
}

class UserNetworkingManager: UserNetworkingManagerProtocol {
    
    
    func buildApiUrl(path: String, parameters: [String : String]) -> URL? {
        
        guard let domainApi = UserDefaults.standard.string(forKey: "selectDomainUser") else {
            return nil
        }
        
        var urlComponents: URL? {
            var components = URLComponents()
            components.scheme = "https"
            components.host = domainApi
            components.path = path
            if !parameters.isEmpty {
                var queryParams = [URLQueryItem]()
                for (value, key) in parameters {
                    queryParams.append(URLQueryItem(name: value, value: key))
                }
                components.queryItems = queryParams
            }
            return components.url
        }
        return urlComponents?.absoluteURL
        
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

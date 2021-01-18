//
//  NetworkingConstants.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 1/14/21.
//

import Foundation

public protocol NetworkingManagerProtocol {
    var host: String { get }
    var clientId: String { get }
    func buildWebasystUrl(_ path: String, parameters: [String: String]) -> URL
}

class NetworkingManager: NetworkingManagerProtocol {
    
    public var host: String = "www.webasyst.com"
    public let clientId: String = "96fa27732ea21b508a24f8599168ed49"
    
    //MARK: Build URL Webasyst Auth
    public func buildWebasystUrl(_ path: String, parameters: [String: String]) -> URL {
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
    
}

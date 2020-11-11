//
//  WXHTTPTarget.swift
//  WebasystX
//
//  Created by Administrator on 11.11.2020.
//

import Foundation

enum WXHTTPMethod: String {
    case post = "POST"
    case get = "GET"
    case delete = "DELETE"
    case put = "PUT"
}

enum WXHTTPAuthorizationType {
    case none
    case basic
    case bearer
    case custom(String)

    public var value: String? {
        switch self {
        case .none: return nil
        case .basic: return "Basic"
        case .bearer: return "Bearer"
        case .custom(let customValue): return customValue
        }
    }
}

enum WXHTTPBody {
    case requestParametrs(parametrs:[String: Any], encoding: WXEncoderType)
}


protocol WXHTTPTarget {
    
    var baseURL: URL { get }
    var path: String { get }
    var method: WXHTTPMethod { get }
    var authorizationType: WXHTTPAuthorizationType { get }
    var body: WXHTTPBody? { get }
    var headers: [String: String]? { get }
    var urlParams: [String: String]? { get }
    var tag: String { get }
}



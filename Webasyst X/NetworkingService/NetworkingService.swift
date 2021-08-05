//
//  NetworkingService.swift
//  Webasyst X
//
//  Created by Виктор Кобыхно on 06.07.2021.
//

import Foundation
import Moya
import Webasyst

enum NetworkingService {
    case requestShopList
    case requestBlogList
    case requestSiteList
    case requestSiteDetail(id: String)
}

extension NetworkingService: TargetType {
    
    var baseURL: URL {
        let webasyst = WebasystApp()
        let selectDomain = UserDefaults.standard.string(forKey: "selectDomainUser") ?? ""
        guard let changeInstall = webasyst.getUserInstall(selectDomain) else { return URL(string: "https://webasyst.com")! }
        return URL(string: changeInstall.url)!
    }
    
    var path: String {
        switch self {
        case .requestBlogList:
            return "/api.php/blog.post.search"
        case .requestShopList:
            return "/api.php/shop.order.search"
        case .requestSiteList:
            return "/api.php/site.page.getList"
        case .requestSiteDetail(id: _):
            return "/api.php/site.page.getInfo"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .requestBlogList:
            return .get
        case .requestShopList:
            return .get
        case .requestSiteList:
            return .get
        case .requestSiteDetail(id: _):
            return .get
        }
    }
    
    var task: Task {
        let webasyst = WebasystApp()
        let selectDomain = UserDefaults.standard.string(forKey: "selectDomainUser") ?? ""
        let changeInstall = webasyst.getUserInstall(selectDomain)
        switch self {
        case .requestBlogList:
            let parameters: [String: Any] = [
                "hash": "author/0",
                "limit": "100",
                "access_token": "\(changeInstall?.accessToken ?? "")"
            ]
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        case .requestShopList:
            let parameters: [String: Any] = [
                "limit": "10",
                "access_token": "\(changeInstall?.accessToken ?? "")"
            ]
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        case .requestSiteList:
            let parameters: [String: String] = [
                "access_token": "\(changeInstall?.accessToken ?? "")",
                "domain_id": "1"
            ]
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        case.requestSiteDetail(id: let id):
            let parameters: [String: String] = [
                "access_token": "\(changeInstall?.accessToken ?? "")",
                "domain_id": "1",
                "id": id
            ]
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        }
    }
    
    var sampleData: Data {
        switch self {
        case .requestBlogList:
            return Data()
        case .requestShopList:
            return Data()
        case .requestSiteList:
            return Data()
        case .requestSiteDetail(id: _):
            return Data()
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
    
}

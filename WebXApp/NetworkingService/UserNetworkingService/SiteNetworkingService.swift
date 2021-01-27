//
//  SiteNetworkingService.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 1/27/21.
//

import Foundation
import Alamofire
import RxSwift

//protocol SiteNetworkingServiceProtocol: class {
//    func getSiteList() -> Observable<Result<SiteList>>
//}
//
//class SiteNetwrokingService: UserNetworkingManager, SiteNetworkingServiceProtocol {
//    
//    private let profileInstallListService = ProfileInstallListService()
//    
//    func getSiteList() -> Observable<Result<SiteList>> {
//        return Observable.create { (observer) -> Disposable in
//            
//            let selectDomain = UserDefaults.standard.string(forKey: "selectDomainUser") ?? ""
//            
//            let parameters: [String: String] = [
//                "access_token": self.profileInstallListService.getTokenActiveInstall(selectDomain)
//            ]
//            
//            
//        }
//        
//        return Disposables
//    }
//    
//}

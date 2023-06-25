//
//  AnalyticsManager.swift
//  Shop-Script
//
//  Created by Леонид Лукашевич on 13.05.2023.
//

import Foundation
import Webasyst
import FirebaseAnalytics
import FirebaseCrashlytics

final class AnalyticsManager {
    
    private init() {}
    
    static func logEvent(_ name: String, parameters: [String : Any]?) {
        Analytics.logEvent(name, parameters: parameters)
    }
    
    static func logError(domain: String, code: Int, userInfo: [String : Any]?) {
        let error = NSError(domain: domain, code: code, userInfo: userInfo)
        Crashlytics.crashlytics().record(error: error)
    }
    
    static func setCrashlyticsKeys(_ keys: [String : Any]) {
        Crashlytics.crashlytics().setCustomKeysAndValues(keys)
    }
    
    static func setupAuthorizedKeys(deleteAll: Bool = false) {
        
        if deleteAll {
            Crashlytics.crashlytics().setCustomKeysAndValues([:])
            return
        }
        
        let webasyst = WebasystApp()
        let group = DispatchGroup()
        
        guard let profileData = webasyst.getProfileData() else { return }
        
        var keys: [String : Any] = [:]
        
        let userInfo: [String : Any] = [
            "firstname": profileData.firstname,
            "lastname": profileData.lastname,
            "middlename": profileData.middlename,
            "name": profileData.name,
            "email": profileData.email,
            "phone": profileData.phone,
            "selectedInstall": String.currentInstall
        ]
        
        if let currentInstall = webasyst.getUserInstall(.currentInstall) {
            let currentInstallInfo: [String : Any] = [
                "domain": currentInstall.domain,
                "id": currentInstall.id,
                "name": currentInstall.name as Any,
                "url": currentInstall.url,
                "accessTokenIsSet": !(currentInstall.accessToken ?? "").isEmpty as Any,
                "cloudPlanId": currentInstall.cloudPlanId as Any,
                "cloudExpireDate": currentInstall.cloudExpireDate as Any,
                "cloudTrial": currentInstall.cloudTrial as Any
            ]
            keys["current_install_info"] = currentInstallInfo
        }
        
        keys["user_info"] = userInfo
        
        group.enter()
        webasyst.getAllUserInstall { installs in
            if let installs = installs {
                for install in installs {
                    let installInfo: [String : Any] = [
                        "id": install.id,
                        "name": install.name as Any,
                        "url": install.url,
                        "accessTokenIsSet": !(install.accessToken ?? "").isEmpty as Any,
                        "cloudPlanId": install.cloudPlanId as Any,
                        "cloudExpireDate": install.cloudExpireDate as Any,
                        "cloudTrial": install.cloudTrial as Any
                    ]
                    keys["install_\(install.domain)"] = installInfo
                }
            }
            group.leave()
        }
        
        let timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { timer in
            timer.invalidate()
            setCrashlyticsKeys(keys)
        }
        
        group.notify(queue: .global()) {
            timer.invalidate()
            setCrashlyticsKeys(keys)
        }
    }
}

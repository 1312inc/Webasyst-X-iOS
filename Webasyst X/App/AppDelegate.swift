//
//  AppDelegate.swift
//  WebXApp
//
//  Created by Administrator on 10.11.2020.
//

import UIKit
import CoreData
import Webasyst


@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let webasyst = WebasystApp()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        webasyst.configure(
            clientId: "96fa27732ea21b508a24f8599168ed49",
            host: "www.webasyst.com",
            scope: "blog.site.shop.webasyst"
        )
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

}


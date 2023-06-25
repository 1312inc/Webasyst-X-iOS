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
class AppDelegate: UIResponder, UIApplicationDelegate, WebasystAppDelegate {
    
    var webasystAppManager: WebasystAppManager!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        webasystAppManager = WebasystAppManager()
        return true
    }
}


//
//  MainTabBar module - MainTabBarRouter.swift
//  Webasyst-X-iOS
//
//  Created by viktkobst on 30/06/2021.
//  Copyright © 2021 1312 Inc.. All rights reserved.
//

import UIKit

//MARK: MainTabBarRouterType
protocol MainTabBarRouterType {
    var navigationController: UINavigationController { get }
    var asembly: AsemblyBuilderProtocol { get }
    init(navigationController: UINavigationController, asembly: AsemblyBuilderProtocol)
    func initialViewController()
}

//MARK MainTabBarRouter
final class MainTabBarRouter: MainTabBarRouterType {
    
    var navigationController: UINavigationController
    var asembly: AsemblyBuilderProtocol
    
    init(navigationController: UINavigationController, asembly: AsemblyBuilderProtocol) {
    
    }
    
    //MARK: Initial ViewController
    func initialViewController() {
    
    }
    
}

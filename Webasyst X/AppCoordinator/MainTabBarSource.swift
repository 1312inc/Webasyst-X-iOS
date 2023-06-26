//
//  MainTabBarCoordinator.swift
//  Finrux
//
//  Created by Виктор Кобыхно on 14.07.2021.
//

import UIKit

enum ViewControllerItem: Int {
    case blog = 0
    case site = 1
    case shop = 2
}

protocol MainTabBarSourceType {
    var items: [UINavigationController] { get set }
}

final class MainTabBarSource: MainTabBarSourceType {
    
    var items: [UINavigationController] = []
    
    init(controllers: [UINavigationController]) {
        self.items = controllers
        setUpIcons()
    }
    
    func setUpIcons() {
        let blogIcon = UIImage(systemName: "pencil")
        self[.blog].tabBarItem = UITabBarItem(title: NSLocalizedString("blogTitle", comment: ""), image: blogIcon, selectedImage: blogIcon)
        let siteIcon = UIImage(systemName: "doc.text")
        self[.site].tabBarItem = UITabBarItem(title: NSLocalizedString("siteTitle", comment: ""), image: siteIcon, selectedImage: siteIcon)
        let shopIcon = UIImage(systemName: "cart")
        self[.shop].tabBarItem = UITabBarItem(title: NSLocalizedString("shopTitle", comment: ""), image: shopIcon, selectedImage: shopIcon)
    }
    
}

extension MainTabBarSource {
    
    subscript(item: ViewControllerItem) -> UINavigationController {
        get {
            guard !items.isEmpty, item.rawValue < items.count, item.rawValue >= 0 else {
                fatalError("item does not exist")
            }
            return items[item.rawValue]
        }
    }
    
}

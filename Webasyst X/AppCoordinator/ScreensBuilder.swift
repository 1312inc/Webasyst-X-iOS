//
//  Screens.swift
//  Finrux
//
//  Created by Виктор Кобыхно on 14.07.2021.
//

import UIKit
import Moya

final class ScreensBuilder: WebasystScreensBuilder {
    
    func createNewBlogViewController(coordinator: BlogCoordinator) -> UIViewController {
        let viewController = BlogViewController()
        let moyaProvider = MoyaProvider<NetworkingService>()
        let viewModel = BlogViewModel(networkingService: moyaProvider)
        viewController.viewModel = viewModel
        viewController.coordinator = coordinator
        return viewController
    }
    
    func createBlogDetailViewController(coordinator: BlogDetailCoordinator, post: PostList) -> UIViewController {
        let viewController = BlogDetailViewController()
        let viewModel = BlogDetailViewModel(post: post)
        viewController.viewModel = viewModel
        viewController.coordinator = coordinator
        return viewController
    }
    
    func createSiteViewController(coordinator: SiteCoordinator) -> UIViewController {
        let viewController = SiteViewController()
        let moyaProvider = MoyaProvider<NetworkingService>()
        let viewModel = SiteViewModel(moyaProvider: moyaProvider)
        viewController.viewModel = viewModel
        viewController.coordinator = coordinator
        return viewController
    }
    
    func createSiteDetailViewController(coordinator: SiteDetailCoordinator, page: String) -> UIViewController {
        let viewController = SiteDetailViewController()
        let moyaProvider = MoyaProvider<NetworkingService>()
        let viewModel = SiteDetailViewModel(networkingService: moyaProvider, page: page)
        viewController.viewModel = viewModel
        viewController.coordinator = coordinator
        return viewController
    }
    
    func createShopViewController(coordinator: ShopCoordinator) -> UIViewController {
        let viewController = ShopViewController()
        let moyaProvider = MoyaProvider<NetworkingService>()
        let viewModel = ShopViewModel(moyaProvider: moyaProvider)
        viewController.viewModel = viewModel
        viewController.coordinator = coordinator
        return viewController
    }
    
}

//MARK: Webasyst X modules
extension ScreensBuilder {
    
    func createWelcomeViewComtroller(coordinator: WelcomeCoordinator) -> UIViewController {
        let viewController = WelcomeViewController()
        let viewModel = WelcomeViewModel()
        viewController.viewModel = viewModel
        viewController.coordinator = coordinator
        return viewController
    }
}

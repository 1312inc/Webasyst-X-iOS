//
//  Screens.swift
//  Finrux
//
//  Created by Виктор Кобыхно on 14.07.2021.
//

import UIKit
import Moya

final class ScreensBuilder {
    
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
    
    func createPhotoViewController(coordinator: PhotoCoordinator) -> UIViewController {
        let viewController = PhotoViewController()
        let moyaProvider = MoyaProvider<NetworkingService>()
        let viewModel = PhotoViewModel(moyaProvider: moyaProvider)
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
    
    func createPhoneAuthViewComtroller(coordinator: PhoneAuthCoordinator) -> UIViewController {
        let viewController = PhoneAuthViewController()
        let viewModel = PhoneAuthViewModel()
        viewController.viewModel = viewModel
        viewController.coordinator = coordinator
        return viewController
    }
    
    func createConfirmPhoneViewController(coordinator: ConfirmPhoneCoordinator, phoneNumber: String) -> UIViewController {
        let viewController = ConfirmPhoneViewController()
        let viewModel = ConfirmPhoneViewModel()
        viewModel.phoneNumber = phoneNumber
        viewController.viewModel = viewModel
        viewController.coordinator = coordinator
        return viewController
    }
    func createSettingsListViewController(coordinator: SettingsListCoordinator) -> UIViewController {
        let viewController = SettingsListViewController()
        let viewModel = SettingsListViewModel()
        viewController.viewModel = viewModel
        viewController.coordinator = coordinator
        return viewController
    }
    
    func createAddAccountViewController(coordinator: AddAccoutCoordinator) -> UIViewController {
        let viewController = AddAccoutViewController()
        let viewModel = AddAccoutViewModel()
        viewController.viewModel = viewModel
        viewController.coordinator = coordinator
        return viewController
    }
    
    func createInstructionWaidViewController(coordinator: InstructionWaidCoordinator) -> UIViewController {
        let viewController = InstructionWaidViewController()
        let viewModel = InstructionWaidViewModel()
        viewController.viewModel = viewModel
        viewController.coordinator = coordinator
        return viewController
    }
    
}

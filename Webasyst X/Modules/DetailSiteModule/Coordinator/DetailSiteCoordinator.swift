//
//  DetailSiteCoordinator.swift
//  Webasyst X
//
//  Created by Виктор Кобыхно on 25.06.2021.
//

import UIKit
import Moya

protocol DetailSiteCoordinatorProtocol {
    
}

final class DetailSiteCoordinator: Coordinator, DetailSiteCoordinatorProtocol {
    
    var childCoordinator: [Coordinator] = []
    private let navigationController: UINavigationController
    private var pageId: String
    
    internal init(childCoordinator: [Coordinator] = [], navigationController: UINavigationController, pageId: String) {
        self.childCoordinator = childCoordinator
        self.navigationController = navigationController
        self.pageId = pageId
    }
    
    func start() {
        let viewController = DetailSiteViewController()
        let moyaProvider = MoyaProvider<NetworkingService>()
        let viewModel = DetailSiteViewModel(moyaProvider: moyaProvider, pageId: self.pageId)
        viewController.viewModel = viewModel
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
}

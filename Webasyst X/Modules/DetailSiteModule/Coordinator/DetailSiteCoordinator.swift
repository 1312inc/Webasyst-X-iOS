//
//  DetailSiteCoordinator.swift
//  Webasyst X
//
//  Created by Виктор Кобыхно on 25.06.2021.
//

import UIKit

protocol DetailSiteCoordinatorProtocol {
    func showAlert(error: ServerError)
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
        let networkingService = SiteNetwrokingService()
        let viewModel = DetailSiteViewModel(networkingService: networkingService, coordinator: self, pageId: self.pageId)
        viewController.viewModel = viewModel
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    func showAlert(error: ServerError) {
        var errorText: String = ""
        switch error {
        case .permisionDenied:
           errorText = NSLocalizedString("permisionDenied", comment: "")
        case .notEntity:
            errorText = NSLocalizedString("getStatusCodeError", comment: "")
        case .requestFailed(text: let text):
            errorText = text
        case .notInstall:
            errorText = NSLocalizedString("installModuleButtonTitle", comment: "")
        }
        let alert = UIAlertController(title: NSLocalizedString("errorTitle", comment: ""), message: errorText, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ок", style: .cancel, handler: nil))
        self.navigationController.present(alert, animated: true) {
            self.navigationController.popViewController(animated: true)
        }
    }
    
    
}

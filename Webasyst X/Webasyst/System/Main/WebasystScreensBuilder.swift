//
//  ScreensBuilder.swift
//  Shop-Script
//
//  Created by Леонид Лукашевич on 05.04.2023.
//

import UIKit
import Moya
import Webasyst

class WebasystScreensBuilder {
    
    // MARK: - Auth
    
    func createAuthViewController(coordinator: AuthCoordinator) -> AuthViewController {
        let viewModel = AuthViewModel()
        let viewController = AuthViewController(coordinator: coordinator, viewModel: viewModel)
        return viewController
    }
    
    func createConfirmPhoneViewController(coordinator: ConfirmPhoneCoordinator, phoneNumber: String) -> ConfirmPhoneViewController {
        let viewController = ConfirmPhoneViewController()
        let viewModel = ConfirmPhoneViewModel()
        viewModel.phoneNumber = phoneNumber
        viewController.viewModel = viewModel
        viewController.coordinator = coordinator
        return viewController
    }
    
    func createQRViewController(coordinator: QRCoordinator, type: QRCoordinator.QRType) -> QRViewController {
        let viewModel = QRViewModel()
        let viewController = QRViewController(viewModel: viewModel, coordinator: coordinator, type: type)
        return viewController
    }
    
    // MARK: - Profile
    
    func createSettingsListViewController(coordinator: SettingsListCoordinator) -> SettingsListViewController {
        let viewController = SettingsListViewController()
        let viewModel = SettingsListViewModel()
        viewController.viewModel = viewModel
        viewController.coordinator = coordinator
        return viewController
    }
    
    func createRedactorViewController(coordinator: RedactorCoordinator, image: UIImage? = nil, profile: ProfileData? = nil, laterNeeded: Bool) -> RedactorViewController {
        let viewController = RedactorViewController(image: image, profile: profile, laterNeeded: laterNeeded)
        let viewModel = RedactorViewModel()
        coordinator.delegate = viewController
        viewController.viewModel = viewModel
        viewController.coordinator = coordinator
        return viewController
    }

    func createAddAccountViewController(coordinator: AddAccountCoordinator) -> AddAccountViewController {
        let viewModel = AddAccountViewModel()
        let viewController = AddAccountViewController(viewModel: viewModel, coordinator: coordinator, bottomBlock: true)
        return viewController
    }
}

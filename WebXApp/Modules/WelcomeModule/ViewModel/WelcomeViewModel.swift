//
//  WelcomeViewModel.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 1/13/21.
//

import Foundation

protocol WelcomeViewModelProtocol: class {
    init(coordinator: WelcomeCoordinatorProtocol, networkingHelper: NetworkingHelperProtocol)
    func tappedLoginButton()
}

final class WelcomeViewModel: WelcomeViewModelProtocol {
    
    var coordinator: WelcomeCoordinatorProtocol
    private var networkingHelper: NetworkingHelperProtocol
    
    init(coordinator: WelcomeCoordinatorProtocol, networkingHelper: NetworkingHelperProtocol) {
        self.coordinator = coordinator
        self.networkingHelper = networkingHelper
    }
    
    public func tappedLoginButton() {
        if networkingHelper.isConnectedToNetwork() {
            coordinator.showWebAuthModal()
        } else {
            coordinator.showConnectionAlert()
        }
        
    }
    
}

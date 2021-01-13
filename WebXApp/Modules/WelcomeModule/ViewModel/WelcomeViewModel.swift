//
//  WelcomeViewModel.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 1/13/21.
//

import Foundation

protocol WelcomeViewModelProtocol: class {
    init(coordinator: WelcomeCoordinatorProtocol)
    func tappedLoginButton()
    func tappedRegisterButton()
}

final class WelcomeViewModel: WelcomeViewModelProtocol {
    
    var coordinator: WelcomeCoordinatorProtocol
    
    init(coordinator: WelcomeCoordinatorProtocol) {
        self.coordinator = coordinator
    }
    
    public func tappedLoginButton() {
        coordinator.showWebAuthModal()
    }
    
    public func tappedRegisterButton() {
        coordinator.showWebRegisterModal()
    }
    
}

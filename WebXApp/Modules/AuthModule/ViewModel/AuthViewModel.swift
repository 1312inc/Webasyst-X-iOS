//
//  AuthViewModel.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 1/13/21.
//

import Foundation

protocol AuthViewModelProtocol: class {
    init(coordinator: AuthCoordinatorProtocol)
}

final class AuthViewModel: AuthViewModelProtocol {
    
    var coordinator: AuthCoordinatorProtocol
    
    init(coordinator: AuthCoordinatorProtocol) {
        self.coordinator = coordinator
    }
}

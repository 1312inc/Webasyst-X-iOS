//
//  AuthViewModel.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 1/13/21.
//a

import Foundation

protocol AuthViewModelProtocol: class {
    var authRequest: URLRequest { get }
    init(networkingService: WebasystAuthNetworkingServicePublicProtocol, coordinator: AuthCoordinatorProtocol)
    func successAuth(code: String, state: String)
}

final class AuthViewModel: AuthViewModelProtocol {
    
    private var networkingService: WebasystAuthNetworkingServicePublicProtocol
    private var coordinator: AuthCoordinatorProtocol
    var authRequest: URLRequest
    
    init(networkingService: WebasystAuthNetworkingServicePublicProtocol, coordinator: AuthCoordinatorProtocol) {
        self.networkingService = networkingService
        self.authRequest = networkingService.buildAuthRequest()
        self.coordinator = coordinator
    }
    
    func successAuth(code: String, state: String) {
        networkingService.getAccessToken(code, stateString: state) { success in
            DispatchQueue.main.async {
                if success {
                    WebasystUserNetworkingService().getUserData { (success) in
                        if success {
                            self.coordinator.successAuth()
                        } else {
                            self.coordinator.errorAuth()
                        }
                    }
                    WebasystUserNetworkingService().getInstallList()
                } else {
                    self.coordinator.errorAuth()
                }
            }
        }
        
    }
    
}

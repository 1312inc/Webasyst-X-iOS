//
//  AuthViewModel.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 1/13/21.
//

import Foundation
import RxSwift

protocol AuthViewModelProtocol: class {
    var authRequest: URLRequest { get }
    init(networkingService: AuthNetworkingServicePublicProtocol, coordinator: AuthCoordinatorProtocol)
    func successAuth(code: String, state: String)
}

final class AuthViewModel: AuthViewModelProtocol {
    
    private var networkingService: AuthNetworkingServicePublicProtocol
    var authRequest: URLRequest
    var coordinator: AuthCoordinatorProtocol
    
    init(networkingService: AuthNetworkingServicePublicProtocol, coordinator: AuthCoordinatorProtocol) {
        self.networkingService = networkingService
        self.authRequest = networkingService.buildAuthRequest()
        self.coordinator = coordinator
    }
    
    func successAuth(code: String, state: String) {
        self.coordinator.successAuth()
        networkingService.getAccessToken(code, stateString: state)
    }
    
}

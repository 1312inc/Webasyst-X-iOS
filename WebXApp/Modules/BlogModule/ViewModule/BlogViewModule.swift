//
//  BlogViewModule.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 1/18/21.
//

import Foundation

protocol BlogViewModelProtocol {
    init(coordinator: BlogCoordinatorProtocol)
    func openInstallList()
}

class BlogViewModel: BlogViewModelProtocol {
    
    private var coordinator: BlogCoordinatorProtocol
    
    required init(coordinator: BlogCoordinatorProtocol) {
        self.coordinator = coordinator
    }
    
    func openInstallList() {
        self.coordinator.openInstallList()
    }
    
}

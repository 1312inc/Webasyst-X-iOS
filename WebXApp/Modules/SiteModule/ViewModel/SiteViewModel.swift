//
//  SiteViewModel.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 1/18/21.
//

import Foundation
import RxSwift
import RxCocoa

protocol SiteViewModelProtocol {
    func openInstallList()
}

final class SiteViewModel: SiteViewModelProtocol {
    
    var coordinator: SiteCoordinatorProtocol
    
    init(coordinator: SiteCoordinatorProtocol) {
        self.coordinator = coordinator
    }
    
    func openInstallList() {
        self.coordinator.openInstallList()
    }
    
}

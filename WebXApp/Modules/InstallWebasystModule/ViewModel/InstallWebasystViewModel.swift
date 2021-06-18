//
//  InstallWebasystViewModel.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 18.06.2021.
//

import Foundation
import RxSwift
import RxCocoa

protocol InstallWebasystViewModelProtocol {
    func openInstruction()
}

final class InstallWebasystViewModel: InstallWebasystViewModelProtocol {
    
    private var coordinator: InstallWebasystCoordinatorProtocol
    
    init(coordinator: InstallWebasystCoordinatorProtocol) {
        self.coordinator = coordinator
    }
    
    func openInstruction() {
        self.coordinator.openInstructionWaid()
    }
    
}

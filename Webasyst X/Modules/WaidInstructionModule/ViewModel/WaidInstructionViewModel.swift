//
//  File.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 18.06.2021.
//

import Foundation

protocol WaidInstructionViewModelProtocol {
    var coordinator: WaidInstructionCoordinatorProtocol { get }
}

final class WaidInstructionViewModel: WaidInstructionViewModelProtocol {
    
    var coordinator: WaidInstructionCoordinatorProtocol
    
    init(coordinator: WaidInstructionCoordinatorProtocol) {
        self.coordinator = coordinator
    }
    
}

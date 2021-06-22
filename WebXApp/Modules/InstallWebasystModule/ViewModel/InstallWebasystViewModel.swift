//
//  InstallWebasystViewModel.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 18.06.2021.
//

import Foundation
import RxSwift
import RxCocoa
import Webasyst

protocol InstallWebasystViewModelProtocol {
    func openInstruction()
}

final class InstallWebasystViewModel: InstallWebasystViewModelProtocol {
    
    private let webasyst = WebasystApp()
    private var coordinator: InstallWebasystCoordinatorProtocol
    
    init(coordinator: InstallWebasystCoordinatorProtocol) {
        self.coordinator = coordinator
    }
    
    func openInstruction() {
        self.coordinator.openInstructionWaid()
    }
    
    func createNewWebasyst() {
//        let queue = DispatchQueue.init(label: "\(Bundle.main.bundleIdentifier ?? "").createNewWebasyst", qos: .background, attributes: .concurrent)
//        queue.async {
//            self.webasyst.createWebasystAccount { success, url in
//                if success {
//
//                } else {
//
//                }
//            }
//        }
    }
    
}

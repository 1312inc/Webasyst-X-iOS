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
    var buttonEnabled: BehaviorSubject<Bool> { get }
    func openInstruction()
    func createNewWebasyst()
}

final class InstallWebasystViewModel: InstallWebasystViewModelProtocol {
    
    private let webasyst = WebasystApp()
    private var coordinator: InstallWebasystCoordinatorProtocol
    var buttonEnabled: BehaviorSubject<Bool> = BehaviorSubject(value: true)
    
    init(coordinator: InstallWebasystCoordinatorProtocol) {
        self.coordinator = coordinator
    }
    
    func openInstruction() {
        self.coordinator.openInstructionWaid()
    }
    
    func createNewWebasyst() {
        buttonEnabled.onNext(false)
        let queue = DispatchQueue.init(label: "\(Bundle.main.bundleIdentifier ?? "").createNewWebasyst", qos: .background, attributes: .concurrent)
        queue.async {
            self.webasyst.createWebasystAccount { success, url in
                if success {
                    self.buttonEnabled.onNext(true)
                    let localizedString = NSLocalizedString("successNewInstall", comment: "")
                    let replacedString = String(format: localizedString, url ?? "")
                    self.coordinator.showAlert(title: NSLocalizedString("successTitle", comment: ""), message: replacedString)
                } else {
                    self.buttonEnabled.onNext(true)
                    self.coordinator.showAlert(title: NSLocalizedString("errorTitle", comment: ""), message: NSLocalizedString("errorCreateNewInstall", comment: ""))
                }
            }
        }
    }
    
}

//
//  AuthViewModel.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 10.06.2021.
//

import Foundation
import RxSwift
import RxCocoa
import Webasyst

public protocol AuthViewModelProtocol {
    func phoneAuth(_ phoneNumber: String)
}

final class AuthViewModel: AuthViewModelProtocol {
    
    private var webasyst = WebasystApp()
    private var coordinator: AuthCoordinatorProtocol
    var enabledButtonSubject: BehaviorSubject<Bool> = BehaviorSubject<Bool>(value: true)
    
    init(_ coordinator: AuthCoordinatorProtocol) {
        self.coordinator = coordinator
    }
    
    func phoneAuth(_ phoneNumber: String) {
        if phoneNumber.count >= 11 {
            self.enabledButtonSubject.onNext(false)
            webasyst.getAuthCode(phoneNumber, type: .phone) { authResult in
                switch authResult {
                case .success:
                    self.coordinator.openCodeScreen(phoneNumber)
                case .no_channels:
                    self.enabledButtonSubject.onNext(true)
                    self.coordinator.showErrorAlert(with: NSLocalizedString("phoneError", comment: ""))
                case .invalid_client:
                    self.enabledButtonSubject.onNext(true)
                    self.coordinator.showErrorAlert(with: NSLocalizedString("clientIdError", comment: ""))
                case .require_code_challenge:
                    self.enabledButtonSubject.onNext(true)
                    self.coordinator.showErrorAlert(with: NSLocalizedString("codeChalengeError", comment: ""))
                case .invalid_email:
                    self.enabledButtonSubject.onNext(true)
                    self.coordinator.showErrorAlert(with: NSLocalizedString("emailError", comment: ""))
                case .invalid_phone:
                    self.enabledButtonSubject.onNext(true)
                    self.coordinator.showErrorAlert(with: NSLocalizedString("phoneError", comment: ""))
                case .request_timeout_limit:
                    self.enabledButtonSubject.onNext(true)
                    self.coordinator.showErrorAlert(with: NSLocalizedString("requestTimeoutLimit", comment: ""))
                case .sent_notification_fail:
                    self.enabledButtonSubject.onNext(true)
                    self.coordinator.showErrorAlert(with: NSLocalizedString("sentNotificationFail", comment: ""))
                case .server_error:
                    self.enabledButtonSubject.onNext(true)
                    self.coordinator.showErrorAlert(with: NSLocalizedString("sentNotificationFail", comment: ""))
                case .undefined(error: let error):
                    self.enabledButtonSubject.onNext(true)
                    self.coordinator.showErrorAlert(with: error)
                }
            }
        } else {
            self.coordinator.showErrorAlert(with: NSLocalizedString("phoneError", comment: ""))
        }
        
    }
    
    
}

//
//  ConfirmPhoneViewModel.swift
//  Shop-Script
//
//  Created by Леонид Лукашевич on 03.10.2022.
//

import Foundation
import RxSwift
import RxCocoa
import Webasyst

//MARK: ConfirmPhoneViewModel
final class ConfirmPhoneViewModel: WebasystViewModelType {
    
    struct Input {
        var verificationCode: AnyObserver<String>
        var submitButtonTap: AnyObserver<Void>
        var resendButtonTap: AnyObserver<Void>
        var resendTimer: AnyObserver<String>
    }
    
    let input: Input
    
    struct Output {
        var submitButtonEnabled: BehaviorSubject<Bool>
        var resendButtonEnabled: BehaviorSubject<Bool>
        var showLoadingHub: BehaviorSubject<Bool>
        var serverStatus: PublishSubject<AuthResult>
        var resendCodeStatus: PublishSubject<AuthResult>
    }
    
    let output: Output
    
    //Передается прошлым контроллером
    public var phoneNumber: String?
    
    private let disposeBag = DisposeBag()
    private let webasyst = WebasystApp()
    
    //MARK: Input Objects
    private var verificationCodeSubject = BehaviorSubject<String>(value: "")
    private var submitButtonTapSubject = PublishSubject<Void>()
    private var resendButtonTapSubject = PublishSubject<Void>()
    private var resendTimerSubject = PublishSubject<String>()
    
    //MARK: Output Objects
    private var submitButtonEnabledSubject = BehaviorSubject<Bool>(value: false)
    private var resendButtonEnabledSubject = BehaviorSubject<Bool>(value: false)
    private var showLoadingHubSubject = BehaviorSubject<Bool>(value: false)
    private var serverStatusSubject = PublishSubject<AuthResult>()
    private var resendCodeStatusSubject = PublishSubject<AuthResult>()
    
    init() {
        //Init input property
        self.input = Input(
            verificationCode: verificationCodeSubject.asObserver(),
            submitButtonTap: submitButtonTapSubject.asObserver(),
            resendButtonTap: resendButtonTapSubject.asObserver(),
            resendTimer: resendTimerSubject.asObserver()
        )
        
        //Init output property
        self.output = Output(
            submitButtonEnabled: submitButtonEnabledSubject.asObserver(),
            resendButtonEnabled: resendButtonEnabledSubject.asObserver(),
            showLoadingHub: showLoadingHubSubject.asObserver(),
            serverStatus: serverStatusSubject.asObserver(),
            resendCodeStatus: resendCodeStatusSubject.asObserver()
        )
        
        verificationCodeSubject
            .filter { !$0.isEmpty }
            .subscribe(onNext: { [weak self] in
                self?.submitVerificationCode($0)
            }).disposed(by: disposeBag)
        
        resendButtonTapSubject
            .subscribe(onNext: { [weak self] in
                self?.resendVericationCode()
            }).disposed(by: disposeBag)
        
    }
    
    private func resendVericationCode() {
        if let phoneNumber = phoneNumber {
            webasyst.getAuthCode(phoneNumber, type: .phone) { [weak self] result in
                self?.resendCodeStatusSubject.onNext(result)
                self?.resendButtonEnabledSubject.onNext(false)
            }
        }
    }
    
    private func submitVerificationCode(_ verificationCode: String) {
        self.webasyst.sendConfirmCode(for: .phone, verificationCode) { [weak self] success in
            if success {
                self?.serverStatusSubject.onNext(.success)
            } else {
                self?.serverStatusSubject.onNext(.undefined(error: .getLocalizedString(withKey: "errorCode")))
            }
        }
    }
    
}

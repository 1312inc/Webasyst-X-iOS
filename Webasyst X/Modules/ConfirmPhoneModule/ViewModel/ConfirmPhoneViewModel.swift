//
//  ConfirmPhone module - ConfirmPhoneViewModel.swift
//  Teamwork
//
//  Created by viktkobst on 21/07/2021.
//  Copyright © 2021 1312 Inc.. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Webasyst

//MARK: ConfirmPhoneViewModel
protocol ConfirmPhoneViewModelType {
    associatedtype Input
    associatedtype Output
    var input: Input { get }
    var output: Output { get }
}

//MARK: ConfirmPhoneViewModel
final class ConfirmPhoneViewModel: ConfirmPhoneViewModelType {
    
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
    
    private var disposeBag = DisposeBag()
            
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
            .map { $0.count >= 6 }
            .subscribe(onNext: { [weak self] valid in
                guard let self = self else { return }
                self.submitButtonEnabledSubject.onNext(valid)
                if valid {
                    self.submitVerificationCode()
                }
            }).disposed(by: disposeBag)
        
        resendButtonTapSubject
            .subscribe(onNext:  { [weak self] in
                guard let self = self else { return }
                self.resendVericationCode()
            }).disposed(by: disposeBag)
        
        submitButtonTapSubject
            .subscribe(onNext:  { [weak self] in
                guard let self = self else { return }
                self.submitVerificationCode()
            }).disposed(by: disposeBag)
        
        //Запускаем таймер для повторной отправки кода
        Timer.scheduledTimer(timeInterval: 90.0, target: self, selector: #selector(self.resendButtonEnabledTimer), userInfo: nil, repeats: false)
    }
    
    private func resendVericationCode() {
        let webasyst = WebasystApp()
        if let phoneNumber = self.phoneNumber {
            webasyst.getAuthCode(phoneNumber, type: .phone) { [weak self] result in
                guard let self = self else { return }
                self.resendCodeStatusSubject.onNext(result)
                self.resendButtonEnabledSubject.onNext(false)
                //Перезапускаем таймер resend
                Timer.scheduledTimer(timeInterval: 90.0, target: self, selector: #selector(self.resendButtonEnabledTimer), userInfo: nil, repeats: false)
            }
        }
    }
    
    private func submitVerificationCode() {
        self.showLoadingHubSubject.onNext(true)
        let webasyst = WebasystApp()
        Observable.of(...)
            .withLatestFrom(verificationCodeSubject)
            .subscribe(onNext: {
                webasyst.sendConfirmCode($0) { [weak self] success in
                    guard let self = self else { return }
                    if success {
                        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                            self.showLoadingHubSubject.onNext(false)
                            self.serverStatusSubject.onNext(.success)
                        }
                    } else {
                        self.showLoadingHubSubject.onNext(false)
                        self.serverStatusSubject.onNext(.undefined(error: NSLocalizedString("errorCode", comment: "")))
                    }
                }
            }).disposed(by: disposeBag)
    }
    
    @objc private func resendButtonEnabledTimer() {
        self.resendButtonEnabledSubject.onNext(true)
    }
    
}

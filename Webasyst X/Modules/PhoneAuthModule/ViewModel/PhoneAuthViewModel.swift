//
//  PhoneAuth module - PhoneAuthViewModel.swift
//  Teamwork
//
//  Created by viktkobst on 20/07/2021.
//  Copyright © 2021 1312 Inc.. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Webasyst

//MARK: PhoneAuthViewModel
protocol PhoneAuthViewModelType {
    associatedtype Input
    associatedtype Output
    var input: Input { get }
    var output: Output { get }
}

//MARK: PhoneAuthViewModel
final class PhoneAuthViewModel: PhoneAuthViewModelType {

    struct Input {
        var phoneNumber: AnyObserver<String>
        var nextButtonTap: AnyObserver<Void>
    }
    
    let input: Input
    
    struct Output {
        var submitButtonEnabled: BehaviorSubject<Bool>
        var showLoadingHub: PublishSubject<Bool>
        var serverStatus: PublishSubject<AuthResult>
    }
    
    let output: Output
    
    private var disposeBag = DisposeBag()
            
    //MARK: Input Objects
    private var phoneNumberSubject = BehaviorSubject<String>(value: "")
    private var nextButtonTapSubject = PublishSubject<Void>()
    private var phoneNumber: String = ""
    
    //MARK: Output Objects
    private var submitButtonEnabledSubject = BehaviorSubject<Bool>(value: false)
    private var showLoadingHubSubject = PublishSubject<Bool>()
    private var serverStatusSubject = PublishSubject<AuthResult>()
    
    init() {
        //Init input property
        self.input = Input(
            phoneNumber: phoneNumberSubject.asObserver(),
            nextButtonTap: nextButtonTapSubject.asObserver()
        )

        //Init output property
        self.output = Output(
            submitButtonEnabled: submitButtonEnabledSubject.asObserver(),
            showLoadingHub: showLoadingHubSubject.asObserver(),
            serverStatus: serverStatusSubject.asObserver()
        )
        
        phoneNumberSubject
            .map { $0.count >= 10 }
            .subscribe(onNext: { [weak self] validate in
                guard let self = self else { return }
                self.submitButtonEnabledSubject.onNext(validate)
            }).disposed(by: disposeBag)
            
        nextButtonTapSubject
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.sendCode()
            }).disposed(by: disposeBag)

    }
    
    private func sendCode() {
        self.showLoadingHubSubject.onNext(true)
        let webasyst = WebasystApp()
        Observable.of(...)
            .withLatestFrom(phoneNumberSubject)
            .subscribe(onNext: {
                webasyst.getAuthCode($0, type: .phone) { [weak self] authResult in
                    guard let self = self else { return }
                    self.showLoadingHubSubject.onNext(false)
                    self.serverStatusSubject.onNext(authResult)
                }
            }).disposed(by: disposeBag)
    }
    
}

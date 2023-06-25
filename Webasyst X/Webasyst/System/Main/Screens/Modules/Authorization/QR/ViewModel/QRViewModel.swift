//
//  QRViewModel.swift
//  Shop-Script
//
//  Created by Леонид Лукашевич on 18.01.2023.
//

import Foundation
import RxSwift
import RxCocoa
import Webasyst

final class QRViewModel: WebasystViewModelType {
    
    struct Input {
        let code: BehaviorRelay<String>
        let sendCode: PublishSubject<String>
    }
    
    let input: Input
    
    struct Output {
        let codeResult: PublishSubject<AuthResult>
    }
    
    let output: Output
    
    //MARK: Input Objects
    private let codeSubject = BehaviorRelay<String>(value: "")
    private let sendCodeSubject = PublishSubject<String>()
    
    //MARK: Output Objects
    private let codeResultSubject = PublishSubject<AuthResult>()
    
    let webasyst = WebasystApp()
    private let disposeBag = DisposeBag()
    
    init() {
        
        //Init input property
        self.input = Input(
            code: codeSubject,
            sendCode: sendCodeSubject.asObserver()
        )
        
        //Init output property
        self.output = Output(
            codeResult: codeResultSubject.asObserver()
        )
        
        sendCodeSubject
            .subscribe(onNext: { [weak self] code in
                self?.submitCode(code)
            })
            .disposed(by: disposeBag)
    }
    
    private func submitCode(_ code: String) {
        self.webasyst.sendConfirmCode(for: .qr, code) { [weak self] success in
            if success {
                self?.codeResultSubject.onNext(.success)
            } else {
                self?.codeResultSubject.onNext(.undefined(error: .getLocalizedString(withKey: "errorQRCode")))
            }
        }
    }
}

//
//  AddAccout module - AddAccoutViewModel.swift
//  Teamwork
//
//  Created by viktkobst on 22/07/2021.
//  Copyright © 2021 1312 Inc.. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Webasyst

//MARK: AddAccoutViewModel
protocol AddAccoutViewModelType {
    associatedtype Input
    associatedtype Output
    var input: Input { get }
    var output: Output { get }
}

//MARK: AddAccoutViewModel
final class AddAccoutViewModel: AddAccoutViewModelType {

    struct Input {
        var createNewAccountTap: AnyObserver<Void>
    }
    
    let input: Input
    
    struct Output {
        var newAccountButtonEnabled: BehaviorSubject<Bool>
        var createAccountResult: PublishSubject<AddAccountResult>
    }
    
    let output: Output
    
    private var disposeBag = DisposeBag()
            
    //MARK: Input Objects
    private var createNewAccoutTapSubject = PublishSubject<Void>()
    
    //MARK: Output Objects
    private var newAccountButtonEnabledSubject = BehaviorSubject<Bool>(value: true)
    private var createAccountResultSubject = PublishSubject<AddAccountResult>()

    init() {
        //Init input property
        self.input = Input(
            createNewAccountTap: createNewAccoutTapSubject.asObserver()
        )

        //Init output property
        self.output = Output(
            newAccountButtonEnabled: newAccountButtonEnabledSubject.asObserver(),
            createAccountResult: createAccountResultSubject.asObserver()
        )
        
        createNewAccoutTapSubject
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.createNewWebasyst()
            }).disposed(by: disposeBag)
    }
    
    private func createNewWebasyst() {
        self.newAccountButtonEnabledSubject.onNext(false)
        let queue = DispatchQueue.init(label: "\(Bundle.main.bundleIdentifier ?? "").createNewWebasyst", qos: .background, attributes: .concurrent)
        let webasyst = WebasystApp()
        queue.async {
            webasyst.createWebasystAccount { [weak self] success, url in
                guard let self = self else { return }
                if success {
                    self.newAccountButtonEnabledSubject.onNext(true)
                    self.createAccountResultSubject.onNext(.success(url: url ?? ""))
                } else {
                    self.newAccountButtonEnabledSubject.onNext(true)
                    self.createAccountResultSubject.onNext(.error)
                }
            }
        }
    }
    
}

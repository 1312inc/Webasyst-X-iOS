//
//  AddAccountViewModel.swift
//  Shop-Script
//
//  Created by Леонид Лукашевич on 18.10.2022.
//

import Foundation
import RxSwift
import RxCocoa
import Webasyst
import Moya

//MARK: AddAccoutViewModel
final class AddAccountViewModel: WebasystViewModelType {
    
    struct Input {
        let createNewAccountTap: AnyObserver<NewShopModel>
        let sendQRCode: AnyObserver<String>
        let sendDigitalCode: AnyObserver<String>
        let digitalCode: BehaviorRelay<String>
    }
    
    let input: Input
    
    struct Output {
        let qrCodeConnectAccountResult: PublishSubject<AddAccountResult>
        let digitalCodeConnectAccountResult: PublishSubject<AddAccountResult>
        let createAccountResult: PublishSubject<AddAccountResult>
    }
    
    let output: Output
    
    fileprivate let disposeBag = DisposeBag()
    fileprivate let webasyst = WebasystApp()
    fileprivate let networking = AddAccountNetworking.shared
    
    //MARK: Input Objects
    fileprivate let createNewAccoutTapSubject = PublishSubject<NewShopModel>()
    fileprivate let sendQRCodeSubject = PublishSubject<String>()
    fileprivate let sendDigitalCodeSubject = PublishSubject<String>()
    fileprivate let digitalCode = BehaviorRelay<String>(value: "")
    
    //MARK: Output Objects
    fileprivate let qrCodeConnectAccountResultSubject = PublishSubject<AddAccountResult>()
    fileprivate let digitalCodeConnectAccountResultSubject = PublishSubject<AddAccountResult>()
    fileprivate let createAccountResultSubject = PublishSubject<AddAccountResult>()
    
    init() {
        //Init input property
        self.input = Input(
            createNewAccountTap: createNewAccoutTapSubject.asObserver(),
            sendQRCode: sendQRCodeSubject.asObserver(),
            sendDigitalCode: sendDigitalCodeSubject.asObserver(),
            digitalCode: digitalCode
        )
        
        //Init output property
        self.output = Output(
            qrCodeConnectAccountResult: qrCodeConnectAccountResultSubject,
            digitalCodeConnectAccountResult: digitalCodeConnectAccountResultSubject.asObserver(),
            createAccountResult: createAccountResultSubject.asObserver()
        )
        
        sendQRCodeSubject
            .subscribe(onNext: { [weak self] code in
                self?.connectWebasystAccountWithQR(withCode: code)
            })
            .disposed(by: disposeBag)
        
        sendDigitalCodeSubject
            .subscribe(onNext: { [weak self] code in
                self?.connectWebasystAccount(withDigitalCode: code)
            })
            .disposed(by: disposeBag)
        
        createNewAccoutTapSubject
            .subscribe(onNext: { [weak self] newShop in
                self?.createNewWebasyst(newShop: newShop)
            })
            .disposed(by: disposeBag)
        
    }
    
    fileprivate lazy var successBlock: (_ id: String?, _ url: String?, _ resultSubject: PublishSubject<AddAccountResult>) -> () = { id, url, resultSubject in
        self.webasyst.checkUserAuth(completion: { [weak self] _ in
            DispatchQueue.main.asyncAfter(wallDeadline: .now() + 3, execute: {
                self?.webasyst.getAllUserInstall { [weak self] installs in
                    let localURL = WebasystApp.url()
                    if let object = try? Data(contentsOf: localURL),
                       let decodedInstall = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSDictionary.self, from: object) as? Dictionary<String?, SettingsListModel>,
                       let installs = installs,
                       let firstIndex = installs.firstIndex(where: { $0.id == id }) {
                        decodedInstall.values.forEach { $0.isLast = false }
                        decodedInstall[installs[firstIndex].accessToken]?.countSelected += 1
                        decodedInstall[installs[firstIndex].accessToken]?.isLast = true
                        UserDefaults.setCurrentInstall(withValue: id)
                        let accountName = installs.first(where: { $0.id == id })?.name
                        resultSubject.onNext(.success(accountName: accountName))
                    }
                }
            })
        })
    }
    
    func connectWebasystAccountWithQR(withCode code: String) {
        networking.connectWebasystAccount(withDigitalCode: code) { [weak self] success, id, url in
            guard let self = self else { return }
            if success {
                self.successBlock(id, url, self.qrCodeConnectAccountResultSubject)
            } else {
                self.qrCodeConnectAccountResultSubject.onNext(.error(description: url))
            }
        }
    }
    
    fileprivate func connectWebasystAccount(withDigitalCode code: String) {
        networking.connectWebasystAccount(withDigitalCode: code) { [weak self] success, id, url in
            guard let self = self else { return }
            if success {
                self.successBlock(id, url, self.digitalCodeConnectAccountResultSubject)
            } else {
                self.digitalCodeConnectAccountResultSubject.onNext(.error(description: url))
            }
        }
    }
    
    fileprivate func createNewWebasyst(newShop: NewShopModel) {
        webasyst.createWebasystAccount(bundle: WebasystNetworkingParameters.addAccount.bundle, plainId: WebasystNetworkingParameters.addAccount.planId,
                                       accountDomain: newShop.domain, accountName: newShop.name) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .successfullyCreated(let id, _):
                UserDefaults.setCurrentInstall(withValue: id)
                self.createAccountResultSubject.onNext(.success(accountName: nil))
            case .successfullyCreatedButNotRenamed(let id, _, let renameError):
                UserDefaults.setCurrentInstall(withValue: id)
                self.createAccountResultSubject.onNext(.success(accountName: renameError))
            case .notCreated(let error):
                self.createAccountResultSubject.onNext(.error(description: error))
            }
        }
    }
}

//
//  Shop module - ShopViewModel.swift
//  Webasyst-X-iOS
//
//  Created by viktkobst on 26/07/2021.
//  Copyright © 2021 1312 Inc.. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Moya
import Webasyst

//MARK: ShopViewModel
protocol ShopViewModelType {
    associatedtype Input
    associatedtype Output
    var input: Input { get }
    var output: Output { get }
}

//MARK: ShopViewModel
final class ShopViewModel: ShopViewModelType {

    struct Input {
       //...
    }
    
    let input: Input
    
    struct Output {
        var ordersList: BehaviorSubject<[Orders]>
        var showLoadingHub: BehaviorSubject<Bool>
        var errorServerRequest: PublishSubject<ServerError>
        var updateActiveSetting: PublishSubject<Bool>
    }
    
    let output: Output
    
    private var disposeBag = DisposeBag()
    private var moyaProvider: MoyaProvider<NetworkingService>
    
    //MARK: Input Objects
    
    //MARK: Output Objects
    private var ordersListSubject = BehaviorSubject<[Orders]>(value: [])
    private var showLoadingHubSubject = BehaviorSubject<Bool>(value: false)
    private var errorServerRequestSubject = PublishSubject<ServerError>()
    private var updateActiveSettingSubject = PublishSubject<Bool>()

    init(moyaProvider: MoyaProvider<NetworkingService>) {
        
        self.moyaProvider = moyaProvider
        
        //Init input property
        self.input = Input(
            //...
        )

        //Init output property
        self.output = Output(
            ordersList: ordersListSubject.asObserver(),
            showLoadingHub: showLoadingHubSubject.asObserver(),
            errorServerRequest: errorServerRequestSubject.asObserver(),
            updateActiveSetting: updateActiveSettingSubject.asObserver()
        )
        
        self.loadServerRequest()
        self.trackingChangeSettings()
    }
    
    private func trackingChangeSettings() {
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(setObserver), name: Notification.Name("ChangedSelectDomain"), object: nil)
    }
    
    @objc private func setObserver() {
        self.updateActiveSettingSubject.onNext(true)
        self.loadServerRequest()
    }
    
    private func loadServerRequest() {
        self.showLoadingHubSubject.onNext(true)
        if Reachability.isConnectedToNetwork() {
            moyaProvider.rx.request(.requestShopList)
                .subscribe { response in
                    guard let statusCode = response.response?.statusCode else {
                        self.showLoadingHubSubject.onNext(false)
                        self.errorServerRequestSubject.onNext(.requestFailed(text: "Failed to get server reply status code"))
                        return
                    }
                    switch statusCode {
                    case 200...299:
                        do {
                            let ordersData = try JSONDecoder().decode(OrderList.self, from: response.data)
                            if !ordersData.orders.isEmpty {
                                self.showLoadingHubSubject.onNext(false)
                                self.ordersListSubject.onNext(ordersData.orders)
                            } else {
                                self.showLoadingHubSubject.onNext(false)
                                self.errorServerRequestSubject.onNext(.notEntity)
                            }
                        } catch let error {
                            self.showLoadingHubSubject.onNext(false)
                            self.errorServerRequestSubject.onNext(.requestFailed(text: error.localizedDescription))
                        }
                    case 401:
                        self.showLoadingHubSubject.onNext(false)
                        do {
                            let json = try JSONSerialization.jsonObject(with: response.data, options: []) as? [String: String]
                            if let error = json?["error"] {
                                if error == "invalid_client" {
                                    let localizedString = NSLocalizedString("invalidClientError", comment: "")
                                    let webasyst = WebasystApp()
                                    let activeDomain = UserDefaults.standard.string(forKey: "selectDomainUser") ?? ""
                                    let activeInstall = webasyst.getUserInstall(activeDomain)
                                    let replacedString = String(format: localizedString, activeInstall?.url ?? "", String(data: response.data, encoding: String.Encoding.utf8)!)
                                    self.errorServerRequestSubject.onNext(.requestFailed(text: replacedString))
                                } else {
                                    self.errorServerRequestSubject.onNext(.requestFailed(text: json?["error_description"] ?? ""))
                                }
                            } else {
                                self.errorServerRequestSubject.onNext(.permisionDenied)
                            }
                        } catch let error {
                            self.errorServerRequestSubject.onNext(.requestFailed(text: error.localizedDescription))
                        }
                    case 400:
                        self.showLoadingHubSubject.onNext(false)
                        self.errorServerRequestSubject.onNext(.notInstall)
                    case 404:
                        do {
                            let json = try JSONSerialization.jsonObject(with: response.data, options: []) as? [String: String]
                            if let error = json?["error"] {
                                if error == "disabled" {
                                    let localizedString = NSLocalizedString("disabledErrorText", comment: "")
                                    self.errorServerRequestSubject.onNext(.requestFailed(text: localizedString))
                                } else {
                                    self.errorServerRequestSubject.onNext(.permisionDenied)
                                }
                            }
                        } catch let error {
                            self.errorServerRequestSubject.onNext(.requestFailed(text: error.localizedDescription))
                        }
                    default:
                        self.showLoadingHubSubject.onNext(false)
                        do {
                            let json = try JSONSerialization.jsonObject(with: response.data, options: []) as? [String: String]
                            self.errorServerRequestSubject.onNext(.requestFailed(text: "\(json?["error_description"] ?? "")"))
                        } catch let error {
                            self.errorServerRequestSubject.onNext(.requestFailed(text: error.localizedDescription))
                        }
                    }
                } onFailure: { error in
                    self.showLoadingHubSubject.onNext(false)
                    self.errorServerRequestSubject.onNext(.requestFailed(text: error.localizedDescription))
                }.disposed(by: disposeBag)
        } else {
            self.errorServerRequestSubject.onNext(.notConnection)
        }
        
    }
    
}

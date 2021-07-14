//
//  ShopViewModel.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 1/18/21.
//

import Foundation
import RxSwift
import RxCocoa
import Moya
import Webasyst

protocol ShopViewModelProtocol: AnyObject {
    var isLoadingSubject: BehaviorSubject<Bool> { get }
    var shopListSubject: BehaviorSubject<[Orders]> { get }
    var errorRequestSubject: PublishSubject<ServerError> { get }
    init(moyaProvider: MoyaProvider<NetworkingService>)
    func changeUserDomain(_ domain: String)
    func fetchOrderList()
}

class ShopViewModel: ShopViewModelProtocol {
    
    var isLoadingSubject = BehaviorSubject<Bool>(value: true)
    var shopListSubject = BehaviorSubject<[Orders]>(value: [])
    var errorRequestSubject = PublishSubject<ServerError>()
    
    private var activeDomain = UserDefaults.standard.string(forKey: "selectDomainUser") ?? ""
    private var moyaProvider: MoyaProvider<NetworkingService>
    private var disposeBag = DisposeBag()
    
    required init(moyaProvider: MoyaProvider<NetworkingService>) {
        self.moyaProvider = moyaProvider
    }
    
    func fetchOrderList() {
        self.isLoadingSubject.onNext(true)
        if Reachability.isConnectedToNetwork() {
            moyaProvider.rx.request(.requestShopList)
                .subscribe { response in
                    guard let statusCode = response.response?.statusCode else {
                        self.isLoadingSubject.onNext(false)
                        self.errorRequestSubject.onNext(.requestFailed(text: "Failed to get server reply status code"))
                        return
                    }
                    switch statusCode {
                    case 200...299:
                        do {
                            let ordersData = try JSONDecoder().decode(OrderList.self, from: response.data)
                            if !ordersData.orders.isEmpty {
                                self.isLoadingSubject.onNext(false)
                                self.shopListSubject.onNext(ordersData.orders)
                            } else {
                                self.isLoadingSubject.onNext(false)
                                self.errorRequestSubject.onNext(.notEntity)
                            }
                        } catch let error {
                            self.isLoadingSubject.onNext(false)
                            self.errorRequestSubject.onNext(.requestFailed(text: error.localizedDescription))
                        }
                    case 401:
                        self.isLoadingSubject.onNext(false)
                        do {
                            let json = try JSONSerialization.jsonObject(with: response.data, options: []) as? [String: String]
                            if let error = json?["error"] {
                                if error == "invalid_client" {
                                    let localizedString = NSLocalizedString("invalidClientError", comment: "")
                                    let webasyst = WebasystApp()
                                    let activeInstall = webasyst.getUserInstall(self.activeDomain)
                                    let replacedString = String(format: localizedString, activeInstall?.url ?? "", String(data: response.data, encoding: String.Encoding.utf8)!)
                                    self.errorRequestSubject.onNext(.requestFailed(text: replacedString))
                                } else {
                                    self.errorRequestSubject.onNext(.requestFailed(text: json?["error_description"] ?? ""))
                                }
                            } else {
                                self.errorRequestSubject.onNext(.permisionDenied)
                            }
                        } catch let error {
                            self.errorRequestSubject.onNext(.requestFailed(text: error.localizedDescription))
                        }
                    case 400:
                        self.isLoadingSubject.onNext(false)
                        self.errorRequestSubject.onNext(.notInstall)
                    case 404:
                        do {
                            let json = try JSONSerialization.jsonObject(with: response.data, options: []) as? [String: String]
                            if let error = json?["error"] {
                                if error == "disabled" {
                                    let localizedString = NSLocalizedString("disabledErrorText", comment: "")
                                    self.errorRequestSubject.onNext(.requestFailed(text: localizedString))
                                } else {
                                    self.errorRequestSubject.onNext(.permisionDenied)
                                }
                            }
                        } catch let error {
                            self.errorRequestSubject.onNext(.requestFailed(text: error.localizedDescription))
                        }
                    default:
                        self.isLoadingSubject.onNext(false)
                        do {
                            let json = try JSONSerialization.jsonObject(with: response.data, options: []) as? [String: String]
                            self.errorRequestSubject.onNext(.requestFailed(text: "\(json?["error_description"] ?? "")"))
                        } catch let error {
                            self.errorRequestSubject.onNext(.requestFailed(text: error.localizedDescription))
                        }
                    }
                } onError: { error in
                    self.isLoadingSubject.onNext(false)
                    self.errorRequestSubject.onNext(.requestFailed(text: error.localizedDescription))
                }.disposed(by: disposeBag)
        } else {
            self.errorRequestSubject.onNext(.notConnection)
        }
        
    }
    
    func changeUserDomain(_ domain: String) {
        if domain != self.activeDomain {
            self.activeDomain = domain
            self.fetchOrderList()
        }
    }
    
}

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

protocol ShopViewModelProtocol: AnyObject {
    var isLoadingSubject: BehaviorSubject<Bool> { get }
    var shopListSubject: BehaviorSubject<[Orders]> { get }
    var errorRequestSubject: PublishSubject<ServerError> { get }
    init(moyaProvider: MoyaProvider<NetworkingService>)
    func changeUserDomain(_ domain: String)
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
        fetchOrderList()
    }
    
    func fetchOrderList() {
        self.isLoadingSubject.onNext(true)
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
                    self.errorRequestSubject.onNext(.permisionDenied)
                case 400:
                    self.isLoadingSubject.onNext(false)
                    self.errorRequestSubject.onNext(.notInstall)
                default:
                    self.isLoadingSubject.onNext(false)
                    self.errorRequestSubject.onNext(.permisionDenied)
                }
            } onError: { error in
                self.isLoadingSubject.onNext(false)
                self.errorRequestSubject.onNext(.requestFailed(text: error.localizedDescription))
            }.disposed(by: disposeBag)
    }
    
    func changeUserDomain(_ domain: String) {
        if domain != self.activeDomain {
            self.activeDomain = domain
            self.fetchOrderList()
        }
    }
    
}

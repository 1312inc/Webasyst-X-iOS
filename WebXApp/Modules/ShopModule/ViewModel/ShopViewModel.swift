//
//  ShopViewModel.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 1/18/21.
//

import Foundation
import RxSwift
import RxCocoa

protocol ShopViewModelProtocol: class {
    var title: String { get }
    var orderList: [Orders] { get }
    var dataSource: BehaviorRelay<Result<[Orders]>> { get }
    init(_ networkingService: ShopNetwrokingServiceProtocol, coordinator: ShopCoordinatorProtocol)
    func fetchOrderList()
    func openInstallList()
    func changeUserDomain(_ domain: String) -> Bool
}

class ShopViewModel: ShopViewModelProtocol {
    
    private var coordinator: ShopCoordinatorProtocol
    private var networkingService: ShopNetwrokingServiceProtocol
    private var activeDomain = UserDefaults.standard.string(forKey: "selectDomainUser") ?? ""
    
    var title = NSLocalizedString("shopTitle", comment: "")
    var orderList = [Orders]()
    var dataSource = BehaviorRelay(value: Result<[Orders]>.Success([]))
    
    required init(_ networkingService: ShopNetwrokingServiceProtocol, coordinator: ShopCoordinatorProtocol) {
        self.networkingService = networkingService
        self.coordinator = coordinator
    }
    
    func fetchOrderList() {
        _ = self.networkingService.getOrdersList().bind(onNext: { (result) in
            switch result {
            case .Success(let orders):
                self.orderList = orders
                self.dataSource.accept(Result.Success(orders))
            case .Failure(let error):
                self.dataSource.accept(Result.Failure(error))
            }
        })
    }
    
    func openInstallList() {
        self.coordinator.openInstallList()
    }
    
    func changeUserDomain(_ domain: String) -> Bool {
        guard domain == self.activeDomain else {
            self.activeDomain = domain
            return false
        }
        self.activeDomain = domain
        return true
    }
    
    
}

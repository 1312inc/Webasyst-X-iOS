//
//  InstalListViewModel.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 1/18/21.
//

import Foundation
import RxSwift

protocol InstallListViewModelProtocol {
    var title: String { get }
    init(networkingService: UserNetworkingServiceProtocol)
    func fetchInstallList() -> Observable<[InstallList]>
}

final class InstallListViewModel: InstallListViewModelProtocol {
    
    let title = "Сменить аккаунт"
    let disposeBag = DisposeBag()
    
    var installList: [InstallList] = []
    private var userNetworkingService: UserNetworkingServiceProtocol
    
    required init(networkingService: UserNetworkingServiceProtocol) {
        self.userNetworkingService = networkingService
    }
    
    func fetchInstallList() -> Observable<[InstallList]> {
        self.userNetworkingService.getInstallList().map {
            $0.map { $0 }
        }
    }
    
}

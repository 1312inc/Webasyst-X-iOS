//
//  InstalListViewModel.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 1/18/21.
//

import Foundation
import RxSwift

protocol InstallListViewModelProtocol {
    var selectDomain: String { get set }
    var title: String { get }
    init(networkingService: WebasystUserNetworkingServiceProtocol, coordinator: InstallListCoordinatorProtocol)
    func fetchInstallList() -> Observable<[InstallList]>
    func selectDomainUser()
    func cancelSelectDomain()
}

final class InstallListViewModel: InstallListViewModelProtocol {
    
    var selectDomain: String = UserDefaults.standard.string(forKey: "selectDomainUser") ?? ""
    let title = "Сменить аккаунт"
    let disposeBag = DisposeBag()
    
    var installList: [InstallList] = []
    private var userNetworkingService: WebasystUserNetworkingServiceProtocol
    var coordinator: InstallListCoordinatorProtocol
    required init(networkingService: WebasystUserNetworkingServiceProtocol, coordinator: InstallListCoordinatorProtocol) {
        self.userNetworkingService = networkingService
        self.coordinator = coordinator
    }
    
    func fetchInstallList() -> Observable<[InstallList]> {
        self.userNetworkingService.getInstallList().map {
            $0.map { $0 }
        }
    }
    
    func selectDomainUser() {
        UserDefaults.standard.setValue(selectDomain, forKey: "selectDomainUser")
        self.coordinator.dismissInstallList()
    }
    
    func cancelSelectDomain() {
        self.coordinator.dismissInstallList()
    }
    
}

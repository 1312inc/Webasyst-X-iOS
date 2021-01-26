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
    init(profileInstallListService: ProfileInstallListServiceProtocol, coordinator: InstallListCoordinatorProtocol)
    func fetchInstallList() -> Observable<[ProfileInstallList]>
    func selectDomainUser()
    func cancelSelectDomain()
}

final class InstallListViewModel: InstallListViewModelProtocol {
    
    var selectDomain: String = UserDefaults.standard.string(forKey: "selectDomainUser") ?? ""
    let title = NSLocalizedString("installListTitle", comment: "")
    let disposeBag = DisposeBag()
    
    var installList: [InstallList] = []
    private var profileInstallListService: ProfileInstallListServiceProtocol
    var coordinator: InstallListCoordinatorProtocol
    required init(profileInstallListService: ProfileInstallListServiceProtocol, coordinator: InstallListCoordinatorProtocol) {
        self.profileInstallListService = profileInstallListService
        self.coordinator = coordinator
    }
    
    func fetchInstallList() -> Observable<[ProfileInstallList]> {
        self.profileInstallListService.getInstallList().map {
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

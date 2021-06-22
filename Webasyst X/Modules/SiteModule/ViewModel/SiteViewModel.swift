//
//  SiteViewModel.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 1/18/21.
//

import Foundation
import RxSwift
import RxCocoa

protocol SiteViewModelProtocol {
    var siteList: [Pages] { get }
    var dataSource: BehaviorRelay<Result<[Pages]>> { get }
    func openInstallList()
    func fetchSiteList()
}

final class SiteViewModel: SiteViewModelProtocol {
    
    private let networkingService: SiteNetworkingServiceProtocol
    var coordinator: SiteCoordinatorProtocol
    var siteList = [Pages]()
    var dataSource = BehaviorRelay(value: Result<[Pages]>.Success([]))
    
    init(coordinator: SiteCoordinatorProtocol, networkingService: SiteNetworkingServiceProtocol) {
        self.coordinator = coordinator
        self.networkingService = networkingService
    }
    
    // Retrieving installation blog entries
    func fetchSiteList() {
        _ = self.networkingService.getSiteList().bind(onNext: { (result) in
            switch result {
            case .Success(let site):
                self.siteList = site
                self.dataSource.accept(Result.Success(site))
            case .Failure(let error):
                self.dataSource.accept(Result.Failure(error))
            }
        })
    }
    
    func openInstallList() {
        self.coordinator.openInstallList()
    }
    
}

//
//  DetailSiteViewModel.swift
//  Webasyst X
//
//  Created by Виктор Кобыхно on 25.06.2021.
//

import Foundation
import RxCocoa
import RxSwift

protocol DetailSiteViewModelProtocol {
    var siteData: BehaviorSubject<DetailSite> { get }
    func loadData()
}

final class DetailSiteViewModel: DetailSiteViewModelProtocol {
    
    private var disposedBag = DisposeBag()
    private var networkingService: SiteNetwrokingService
    private var coordinator: DetailSiteCoordinatorProtocol
    private var pageId: String
    var siteData: BehaviorSubject<DetailSite> = BehaviorSubject<DetailSite>(value: DetailSite(id: "", name: "", title: "", content: "", update_datetime: ""))
    
    internal init(networkingService: SiteNetwrokingService, coordinator: DetailSiteCoordinatorProtocol, pageId: String) {
        self.networkingService = networkingService
        self.coordinator = coordinator
        self.pageId = pageId
    }
    
    func loadData() {
        self.networkingService.getDetailSite(id: self.pageId)
            .subscribe(onNext: { result in
                switch result {
                case .Success(let data):
                    self.siteData.onNext(data)
                case .Failure(let error):
                    self.coordinator.showAlert(error: error)
                }
            }).disposed(by: self.disposedBag)
    }
    
}

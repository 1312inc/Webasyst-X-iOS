//
//  DetailSiteViewModel.swift
//  Webasyst X
//
//  Created by Виктор Кобыхно on 25.06.2021.
//

import Foundation
import RxCocoa
import RxSwift
import Moya

protocol DetailSiteViewModelProtocol {
    var isLoadingSubject: BehaviorSubject<Bool> { get }
    var siteDetailSubject: BehaviorSubject<DetailSite> { get }
    var errorRequestSubject: PublishSubject<ServerError> { get }
    init(moyaProvider: MoyaProvider<NetworkingService>, pageId: String)
}

final class DetailSiteViewModel: DetailSiteViewModelProtocol {
    
    var isLoadingSubject = BehaviorSubject<Bool>(value: true)
    var siteDetailSubject = BehaviorSubject<DetailSite>(value: DetailSite(id: "", name: "", title: "", content: "", update_datetime: ""))
    var errorRequestSubject = PublishSubject<ServerError>()
    
    private var moyaProvider: MoyaProvider<NetworkingService>
    private var disposeBag = DisposeBag()
    private var pageId: String
    
    init(moyaProvider: MoyaProvider<NetworkingService>, pageId: String) {
        self.moyaProvider = moyaProvider
        self.pageId = pageId
        self.loadData()
    }
    
    func loadData() {
        isLoadingSubject.onNext(true)
        moyaProvider.rx.request(.requestSiteDetail(id: self.pageId))
            .debug()
            .subscribe { response in
                guard let statusCode = response.response?.statusCode else {
                    self.isLoadingSubject.onNext(false)
                    self.errorRequestSubject.onNext(.requestFailed(text: "Failed to get server reply status code"))
                    return
                }
                switch statusCode {
                case 200...299:
                    do {
                        let siteData = try JSONDecoder().decode(DetailSite.self, from: response.data)
                        self.isLoadingSubject.onNext(false)
                        self.siteDetailSubject.onNext(siteData)
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
    
}

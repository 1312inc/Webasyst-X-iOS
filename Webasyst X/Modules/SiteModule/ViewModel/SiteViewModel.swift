//
//  SiteViewModel.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 1/18/21.
//

import Foundation
import RxSwift
import RxCocoa
import Moya

protocol SiteViewModelProtocol {
    var isLoadingSubject: BehaviorSubject<Bool> { get }
    var siteListSubject: BehaviorSubject<[Pages]> { get }
    var errorRequestSubject: PublishSubject<ServerError> { get }
    init(moyaProvider: MoyaProvider<NetworkingService>)
    func changeUserDomain(_ domain: String)
}

final class SiteViewModel: SiteViewModelProtocol {
    
    var isLoadingSubject = BehaviorSubject<Bool>(value: true)
    var siteListSubject = BehaviorSubject<[Pages]>(value: [])
    var errorRequestSubject = PublishSubject<ServerError>()
    
    private var activeDomain = UserDefaults.standard.string(forKey: "selectDomainUser") ?? ""
    private var moyaProvider: MoyaProvider<NetworkingService>
    private var disposeBag = DisposeBag()
    
    init(moyaProvider: MoyaProvider<NetworkingService>) {
        self.moyaProvider = moyaProvider
        self.fetchSiteList()
    }
    
    // Retrieving installation blog entries
    func fetchSiteList() {
        self.isLoadingSubject.onNext(true)
        moyaProvider.rx.request(.requestSiteList)
            .subscribe { response in
                guard let statusCode = response.response?.statusCode else {
                    self.isLoadingSubject.onNext(false)
                    self.errorRequestSubject.onNext(.requestFailed(text: "Failed to get server reply status code"))
                    return
                }
                switch statusCode {
                case 200...299:
                    do {
                        let siteData = try JSONDecoder().decode(SiteList.self, from: response.data)
                        if let sites = siteData.pages {
                            if !sites.isEmpty {
                                self.isLoadingSubject.onNext(false)
                                self.siteListSubject.onNext(sites)
                            } else {
                                self.isLoadingSubject.onNext(false)
                                self.errorRequestSubject.onNext(.notEntity)
                            }
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
            self.fetchSiteList()
        }
    }
    
}

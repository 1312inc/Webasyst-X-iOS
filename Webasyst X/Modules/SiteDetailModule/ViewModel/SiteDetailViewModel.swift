//
//  SiteDetail module - SiteDetailViewModel.swift
//  Webasyst-X-iOS
//
//  Created by viktkobst on 26/07/2021.
//  Copyright © 2021 1312 Inc.. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Moya

//MARK: SiteDetailViewModel
protocol SiteDetailViewModelType {
    associatedtype Input
    associatedtype Output
    var input: Input { get }
    var output: Output { get }
}

//MARK: SiteDetailViewModel
final class SiteDetailViewModel: SiteDetailViewModelType {

    private var page: String
    
    struct Input {
        //...
    }
    
    let input: Input
    
    struct Output {
        var pageData: PublishSubject<DetailSite>
        var showLoadingHub: BehaviorSubject<Bool>
        var errorServerRequest: PublishSubject<ServerError>
    }
    
    let output: Output
    
    private var disposeBag = DisposeBag()
    private var networkingService: MoyaProvider<NetworkingService>
            
    //MARK: Input Objects
    
    //MARK: Output Objects
    private var pageDataSubject = PublishSubject<DetailSite>()
    private var showLoadingHubSubject = BehaviorSubject<Bool>(value: false)
    private var errorServerRequestSubject = PublishSubject<ServerError>()

    init(networkingService: MoyaProvider<NetworkingService>, page: String) {
        
        self.page = page
        self.networkingService = networkingService
        
        //Init input property
        self.input = Input(
            //...
        )

        //Init output property
        self.output = Output(
            pageData: pageDataSubject.asObserver(),
            showLoadingHub: showLoadingHubSubject.asObserver(),
            errorServerRequest: errorServerRequestSubject.asObserver()
        )
        
        self.loadServerRequest()
    }
    
    private func loadServerRequest() {
        showLoadingHubSubject.onNext(true)
        networkingService.rx.request(.requestSiteDetail(id: page))
            .debug()
            .subscribe { response in
                guard let statusCode = response.response?.statusCode else {
                    self.showLoadingHubSubject.onNext(false)
                    self.errorServerRequestSubject.onNext(.requestFailed(text: "Failed to get server reply status code"))
                    return
                }
                switch statusCode {
                case 200...299:
                    do {
                        let siteData = try JSONDecoder().decode(DetailSite.self, from: response.data)
                        self.showLoadingHubSubject.onNext(false)
                        self.pageDataSubject.onNext(siteData)
                    } catch let error {
                        self.showLoadingHubSubject.onNext(false)
                        self.errorServerRequestSubject.onNext(.requestFailed(text: error.localizedDescription))
                    }
                case 401:
                    self.showLoadingHubSubject.onNext(false)
                    self.errorServerRequestSubject.onNext(.permisionDenied)
                case 400:
                    self.showLoadingHubSubject.onNext(false)
                    self.errorServerRequestSubject.onNext(.notInstall)
                default:
                    self.showLoadingHubSubject.onNext(false)
                    self.errorServerRequestSubject.onNext(.permisionDenied)
                }
            } onError: { error in
                self.showLoadingHubSubject.onNext(false)
                self.errorServerRequestSubject.onNext(.requestFailed(text: error.localizedDescription))
            }.disposed(by: disposeBag)
    }
    
}

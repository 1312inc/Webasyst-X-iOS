//
//  Site module - SiteViewModel.swift
//  Webasyst-X-iOS
//
//  Created by viktkobst on 26/07/2021.
//  Copyright © 2021 1312 Inc.. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Moya
import Webasyst

//MARK: SiteViewModel
protocol SiteViewModelType {
    associatedtype Input
    associatedtype Output
    var input: Input { get }
    var output: Output { get }
}

//MARK: SiteViewModel
final class SiteViewModel: SiteViewModelType {

    struct Input {
       //...
    }
    
    let input: Input
    
    struct Output {
        var pageList: BehaviorSubject<[Pages]>
        var showLoadingHub: BehaviorSubject<Bool>
        var errorServerRequest: PublishSubject<ServerError>
        var updateActiveSetting: PublishSubject<Bool>
    }
    
    let output: Output
    
    private var disposeBag = DisposeBag()
    private var moyaProvider: MoyaProvider<NetworkingService>
            
    //MARK: Input Objects
    
    //MARK: Output Objects
    private var pageListSubject = BehaviorSubject<[Pages]>(value: [])
    private var showLoadingHubSubject = BehaviorSubject<Bool>(value: false)
    private var errorServerRequestSubject = PublishSubject<ServerError>()
    private var updateActiveSettingSubject = PublishSubject<Bool>()

    init(moyaProvider: MoyaProvider<NetworkingService>) {
        
        self.moyaProvider = moyaProvider
        
        //Init input property
        self.input = Input(
            //...
        )

        //Init output property
        self.output = Output(
            pageList: pageListSubject.asObserver(),
            showLoadingHub: showLoadingHubSubject.asObserver(),
            errorServerRequest: errorServerRequestSubject.asObserver(),
            updateActiveSetting: updateActiveSettingSubject.asObserver()
        )
        
        self.loadRequestPages()
        self.trackingChangeSettings()
    }
    
    private func trackingChangeSettings() {
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(setObserver), name: Notification.Name("ChangedSelectDomain"), object: nil)
    }
    
    @objc private func setObserver() {
        self.updateActiveSettingSubject.onNext(true)
        self.loadRequestPages()
    }
    
    private func loadRequestPages() {
        self.showLoadingHubSubject.onNext(true)
        if Reachability.isConnectedToNetwork() {
            moyaProvider.rx.request(.requestSiteList)
                .subscribe { response in
                    guard let statusCode = response.response?.statusCode else {
                        self.showLoadingHubSubject.onNext(false)
                        self.errorServerRequestSubject.onNext(.requestFailed(text: "Failed to get server reply status code"))
                        return
                    }
                    switch statusCode {
                    case 200...299:
                        do {
                            let siteData = try JSONDecoder().decode(SiteList.self, from: response.data)
                            if let sites = siteData.pages {
                                if !sites.isEmpty {
                                    self.showLoadingHubSubject.onNext(false)
                                    self.pageListSubject.onNext(sites)
                                } else {
                                    self.showLoadingHubSubject.onNext(false)
                                    self.errorServerRequestSubject.onNext(.notEntity)
                                }
                            } else {
                                self.showLoadingHubSubject.onNext(false)
                                self.errorServerRequestSubject.onNext(.notEntity)
                            }
                        } catch let error {
                            self.showLoadingHubSubject.onNext(false)
                            self.errorServerRequestSubject.onNext(.requestFailed(text: error.localizedDescription))
                        }
                    case 401:
                        self.showLoadingHubSubject.onNext(false)
                        do {
                            let json = try JSONSerialization.jsonObject(with: response.data, options: []) as? [String: String]
                            if let error = json?["error"] {
                                if error == "invalid_client" {
                                    let localizedString = NSLocalizedString("invalidClientError", comment: "")
                                    let webasyst = WebasystApp()
                                    let activeDomain = UserDefaults.standard.string(forKey: "selectDomainUser") ?? ""
                                    let activeInstall = webasyst.getUserInstall(activeDomain)
                                    let replacedString = String(format: localizedString, activeInstall?.url ?? "", String(data: response.data, encoding: String.Encoding.utf8)!)
                                    self.errorServerRequestSubject.onNext(.requestFailed(text: replacedString))
                                } else {
                                    self.errorServerRequestSubject.onNext(.requestFailed(text: json?["error_description"] ?? ""))
                                }
                            } else {
                                self.errorServerRequestSubject.onNext(.accessDenied)
                            }
                        } catch let error {
                            self.errorServerRequestSubject.onNext(.requestFailed(text: error.localizedDescription))
                        }
                    case 400:
                        self.showLoadingHubSubject.onNext(false)
                        self.errorServerRequestSubject.onNext(.notInstall)
                    case 404:
                        do {
                            let json = try JSONSerialization.jsonObject(with: response.data, options: []) as? [String: String]
                            if let error = json?["error"] {
                                if error == "disabled" {
                                    let localizedString = NSLocalizedString("disabledErrorText", comment: "")
                                    self.errorServerRequestSubject.onNext(.requestFailed(text: localizedString))
                                } else {
                                    self.errorServerRequestSubject.onNext(.accessDenied)
                                }
                            }
                        } catch let error {
                            self.errorServerRequestSubject.onNext(.requestFailed(text: error.localizedDescription))
                        }
                    default:
                        self.showLoadingHubSubject.onNext(false)
                        do {
                            let json = try JSONSerialization.jsonObject(with: response.data, options: []) as? [String: String]
                            if let error = json?["error_description"] {
                                self.errorServerRequestSubject.onNext(.requestFailed(text: error))
                            } else {
                                self.errorServerRequestSubject.onNext(.accessDenied)
                            }
                            
                        } catch let error {
                            self.errorServerRequestSubject.onNext(.requestFailed(text: error.localizedDescription))
                        }
                    }
                } onFailure: { error in
                    self.showLoadingHubSubject.onNext(false)
                    self.errorServerRequestSubject.onNext(.requestFailed(text: error.localizedDescription))
                }.disposed(by: disposeBag)
        } else {
            self.errorServerRequestSubject.onNext(.notConnection)
        }
    }
    
}

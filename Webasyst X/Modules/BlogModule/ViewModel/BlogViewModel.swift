//
//  NewBlog module - NewBlogViewModel.swift
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

//MARK: NewBlogViewModel
protocol BlogViewModelType {
    associatedtype Input
    associatedtype Output
    var input: Input { get }
    var output: Output { get }
}

//MARK: NewBlogViewModel
final class BlogViewModel: BlogViewModelType {

    struct Input {
       //...
    }
    
    let input: Input
    
    struct Output {
        var postList: BehaviorSubject<[PostList]>
        var showLoadingHub: BehaviorSubject<Bool>
        var errorServerRequest: PublishSubject<ServerError>
        var updateActiveSetting: PublishSubject<Bool>
    }
    
    let output: Output
    
    private var disposeBag = DisposeBag()
    private var networkingService: MoyaProvider<NetworkingService>
            
    //MARK: Input Objects
    
    //MARK: Output Objects
    private var postListSubject = BehaviorSubject<[PostList]>(value: [])
    private var showLoadingHubSubject = BehaviorSubject<Bool>(value: false)
    private var errorServerRequestSubject = PublishSubject<ServerError>()
    private var updateActiveSettingSubject = PublishSubject<Bool>()

    init(networkingService: MoyaProvider<NetworkingService>) {
        
        self.networkingService = networkingService
        
        //Init input property
        self.input = Input(
            //...
        )

        //Init output property
        self.output = Output(
            postList: postListSubject.asObserver(),
            showLoadingHub: showLoadingHubSubject.asObserver(),
            errorServerRequest: errorServerRequestSubject.asObserver(),
            updateActiveSetting: updateActiveSettingSubject.asObserver()
        )
        
        self.serverLoadRequst()
        self.trackingChangeSettings()
    }
    
    private func trackingChangeSettings() {
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(setObserver), name: Notification.Name("ChangedSelectDomain"), object: nil)
    }
    
    @objc private func setObserver() {
        self.updateActiveSettingSubject.onNext(true)
        self.serverLoadRequst()
    }
    
    private func serverLoadRequst() {
        showLoadingHubSubject.onNext(true)
        if Reachability.isConnectedToNetwork() {
            networkingService.rx.request(.requestBlogList)
                .subscribe { response in
                    guard let statusCode = response.response?.statusCode else {
                        self.showLoadingHubSubject.onNext(false)
                        self.errorServerRequestSubject.onNext(.requestFailed(text: "Failed to get server reply status code"))
                        return
                    }
                    switch statusCode {
                    case 200...299:
                        do {
                            let postData = try JSONDecoder().decode(PostsBlog.self, from: response.data)
                            if let posts = postData.posts {
                                if !posts.isEmpty {
                                    self.showLoadingHubSubject.onNext(false)
                                    self.postListSubject.onNext(posts)
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
                                } else if error == "disabled" {
                                    let localizedString = NSLocalizedString("disabledErrorText", comment: "")
                                    self.errorServerRequestSubject.onNext(.requestFailed(text: localizedString))
                                } else {
                                    self.errorServerRequestSubject.onNext(.requestFailed(text: json?["error_description"] ?? ""))
                                }
                            } else {
                                self.errorServerRequestSubject.onNext(.permisionDenied)
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
                                if error == "invalid_client" {
                                    let localizedString = NSLocalizedString("invalidClientError", comment: "")
                                    let webasyst = WebasystApp()
                                    let activeDomain = UserDefaults.standard.string(forKey: "selectDomainUser") ?? ""
                                    let activeInstall = webasyst.getUserInstall(activeDomain)
                                    let replacedString = String(format: localizedString, activeInstall?.url ?? "", String(data: response.data, encoding: String.Encoding.utf8)!)
                                    self.errorServerRequestSubject.onNext(.requestFailed(text: replacedString))
                                } else if error == "disabled" {
                                    let localizedString = NSLocalizedString("disabledErrorText", comment: "")
                                    self.errorServerRequestSubject.onNext(.requestFailed(text: localizedString))
                                } else {
                                    self.errorServerRequestSubject.onNext(.requestFailed(text: json?["error_description"] ?? ""))
                                }
                            }
                        } catch let error {
                            self.errorServerRequestSubject.onNext(.requestFailed(text: error.localizedDescription))
                        }
                    default:
                        self.showLoadingHubSubject.onNext(false)
                        do {
                            let json = try JSONSerialization.jsonObject(with: response.data, options: []) as? [String: String]
                            self.errorServerRequestSubject.onNext(.requestFailed(text: "\(json?["error_description"] ?? "")"))
                        } catch let error {
                            self.errorServerRequestSubject.onNext(.requestFailed(text: error.localizedDescription))
                        }
                    }
                } onError: { error in
                    self.showLoadingHubSubject.onNext(false)
                    self.errorServerRequestSubject.onNext(.requestFailed(text: error.localizedDescription))
                }.disposed(by: disposeBag)
        } else {
            self.errorServerRequestSubject.onNext(.notConnection)
        }
    }
    
}

//
//  PhotoViewModel.swift
//  Webasyst X
//
//  Created by Леонид Лукашевич on 18.09.2022.
//

import Foundation
import RxSwift
import RxCocoa
import Moya
import Webasyst


//MARK: ShopViewModel
protocol PhotoViewModelType {
    associatedtype Input
    associatedtype Output
    var input: Input { get }
    var output: Output { get }
}

final class PhotoViewModel: PhotoViewModelType {
   
    struct Input {
       //...
    }
    
    let input: Input
    
    struct Output {
        var photosList: BehaviorSubject<[Photos]>
        var showLoadingHub: BehaviorSubject<Bool>
        var errorServerRequest: PublishSubject<ServerError>
        var updateActiveSetting: PublishSubject<Bool>
    }
    
    let output: Output
    
    private var disposeBag = DisposeBag()
    private var moyaProvider: MoyaProvider<NetworkingService>
    
    //MARK: Input Objects
    
    //MARK: Output Objects
    private var photosListSubject = BehaviorSubject<[Photos]>(value: [])
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
            photosList: photosListSubject.asObserver(),
            showLoadingHub: showLoadingHubSubject.asObserver(),
            errorServerRequest: errorServerRequestSubject.asObserver(),
            updateActiveSetting: updateActiveSettingSubject.asObserver()
        )
        
        self.loadServerRequest()
        self.trackingChangeSettings()
    }
    
    private func trackingChangeSettings() {
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(setObserver), name: Notification.Name("ChangedSelectDomain"), object: nil)
    }
    
    @objc private func setObserver() {
        self.updateActiveSettingSubject.onNext(true)
        self.loadServerRequest()
    }
    
    private func loadServerRequest() {
        self.showLoadingHubSubject.onNext(true)
        if Reachability.isConnectedToNetwork() {
            print(moyaProvider.rx.request(.requestPhotoList))
            moyaProvider.rx.request(.requestPhotoList)
                .subscribe { response in
                    guard let statusCode = response.response?.statusCode else {
                        self.showLoadingHubSubject.onNext(false)
                        self.errorServerRequestSubject.onNext(.requestFailed(text: "Failed to get server reply status code"))
                        return
                    }
                    switch statusCode {
                    case 200...299:
                        do {
                            print(response)
                            print(response.data)
                            let photosData = try JSONDecoder().decode(PhotoList.self, from: response.data)
                            if !photosData.photos.isEmpty {
                                self.showLoadingHubSubject.onNext(false)
                                self.photosListSubject.onNext(photosData.photos)
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
                                if error == "disabled" {
                                    let localizedString = NSLocalizedString("disabledErrorText", comment: "")
                                    self.errorServerRequestSubject.onNext(.requestFailed(text: localizedString))
                                } else {
                                    self.errorServerRequestSubject.onNext(.permisionDenied)
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
                } onFailure: { error in
                    self.showLoadingHubSubject.onNext(false)
                    self.errorServerRequestSubject.onNext(.requestFailed(text: error.localizedDescription))
                }.disposed(by: disposeBag)
        } else {
            self.errorServerRequestSubject.onNext(.notConnection)
        }
        
    }
}

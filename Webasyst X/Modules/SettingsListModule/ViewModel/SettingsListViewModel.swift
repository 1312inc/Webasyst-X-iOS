//
//  SettingsList module - SettingsListViewModel.swift
//  Teamwork
//
//  Created by viktkobst on 21/07/2021.
//  Copyright © 2021 1312 Inc.. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Webasyst

//MARK: SettingsListViewModel
protocol SettingsListViewModelType {
    associatedtype Input
    associatedtype Output
    var input: Input { get }
    var output: Output { get }
}

//MARK: SettingsListViewModel
final class SettingsListViewModel: SettingsListViewModelType {

    struct Input {
        var logOutUserTap: AnyObserver<Void>
        var changeActiveSetting: AnyObserver<UserInstall>
    }
    
    let input: Input
    
    struct Output {
        var installList: BehaviorSubject<[UserInstall]>
        var userProfileData: BehaviorSubject<ProfileData>
        var userLogOutStatus: BehaviorSubject<Bool>
        var settingChange: BehaviorSubject<Bool>
        var errorGetUserInstall: PublishSubject<ServerError>
    }
    
    let output: Output
    
    private var disposeBag = DisposeBag()
            
    //MARK: Input Objects
    private var logOutUserTapSubject = PublishSubject<Void>()
    private var changeActiveSettingSubject = PublishSubject<UserInstall>()
    
    //MARK: Output Objects
    private var settingsListSubject = BehaviorSubject<[UserInstall]>(value: [])
    private var userProfileDataSubject = BehaviorSubject<ProfileData>(value: ProfileData(name: "", firstname: "", lastname: "", middlename: "", email: "", userpic_original_crop: nil))
    private var logOutUserStatusSubject = BehaviorSubject<Bool>(value: false)
    private var settingChangeSubject = BehaviorSubject<Bool>(value: false)
    private var errorGetUserInstallSubject = PublishSubject<ServerError>()

    init() {
        //Init input property
        self.input = Input(
            logOutUserTap: logOutUserTapSubject.asObserver(),
            changeActiveSetting: changeActiveSettingSubject.asObserver()
        )

        //Init output property
        self.output = Output(
            installList: settingsListSubject.asObserver(),
            userProfileData: userProfileDataSubject.asObserver(),
            userLogOutStatus: logOutUserStatusSubject.asObserver(),
            settingChange: settingChangeSubject.asObserver(),
            errorGetUserInstall: errorGetUserInstallSubject.asObserver()
        )
        
        logOutUserTapSubject
            .subscribe(onNext: {
                let webasyst = WebasystApp()
                webasyst.logOutUser { [weak self] logout in
                    guard let self = self else { return }
                    self.logOutUserStatusSubject.onNext(logout)
                }
            }).disposed(by: disposeBag)
        
        changeActiveSettingSubject
            .subscribe(onNext: { [weak self] install in
                guard let self = self else { return }
                UserDefaults.standard.setValue(install.id, forKey: "selectDomainUser")
                let nc = NotificationCenter.default
                nc.post(name: Notification.Name("ChangedSelectDomain"), object: nil)
                self.settingChangeSubject.onNext(true)
            }).disposed(by: disposeBag)
        
        self.fetchInstallList()
        self.getUserData()
    }
    
    private func fetchInstallList() {
        let webasyst = WebasystApp()
        webasyst.getAllUserInstall { [weak self] userInstalls in
            guard let self = self else { return }
            guard let installs = userInstalls else {
                self.errorGetUserInstallSubject.onNext(.notEntity)
                return
            }
            self.settingsListSubject.onNext(installs)
        }
    }
    
    private func getUserData() {
        let webasyst = WebasystApp()
        if let profile = webasyst.getProfileData() {
            self.userProfileDataSubject.onNext(profile)
        }
    }
    
}

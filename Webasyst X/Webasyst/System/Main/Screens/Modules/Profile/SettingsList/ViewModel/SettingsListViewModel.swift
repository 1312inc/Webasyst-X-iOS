//
//  SettingsListViewModel.swift
//  Shop-Script
//
//  Created by Леонид Лукашевич on 05.10.2022.
//

import Foundation
import RxSwift
import RxCocoa
import Webasyst

//MARK: SettingsListViewModel
final class SettingsListViewModel: WebasystViewModelType {
    
    let webasyst = WebasystApp()
        
    struct Input {
        var logOutUserTap: AnyObserver<Void>
        var changeActiveSetting: PublishRelay<UserInstall>
        var refreshProfile: PublishRelay<UpdateNeeded>
        var callCoordinatorComplition: PublishSubject<Bool>
    }
    
    let input: Input
    
    struct Output {
        var installList: BehaviorSubject<[UserInstall]>
        var userProfileData: BehaviorSubject<ProfileData>
        var userLogOutStatus: BehaviorSubject<Bool>
        var settingChange: PublishRelay<Bool>
    }
    
    let output: Output
    
    private var disposeBag = DisposeBag()
    
    //MARK: Input Objects
    private var logOutUserTapSubject = PublishSubject<Void>()
    private var changeActiveSettingSubject = PublishRelay<UserInstall>()
    private var refreshProfile = PublishRelay<UpdateNeeded>()
    private var callCoordinatorComplitionSubject = PublishSubject<Bool>()
    
    //MARK: Output Objects
    private var settingsListSubject = BehaviorSubject<[UserInstall]>(value: [])
    private var userProfileDataSubject = BehaviorSubject<ProfileData>(value: ProfileData(name: "", firstname: "", lastname: "", middlename: "", email: "", phone: "", userpic_original_crop: nil))
    private var logOutUserStatusSubject = BehaviorSubject<Bool>(value: false)
    private var settingChangeSubject = PublishRelay<Bool>()
    
    init(withInstallsUpdate: Bool = true) {
        //Init input property
        self.input = Input(
            logOutUserTap: logOutUserTapSubject.asObserver(),
            changeActiveSetting: changeActiveSettingSubject,
            refreshProfile: refreshProfile,
            callCoordinatorComplition: callCoordinatorComplitionSubject.asObserver()
        )
        
        //Init output property
        self.output = Output(
            installList: settingsListSubject.asObserver(),
            userProfileData: userProfileDataSubject.asObserver(),
            userLogOutStatus: logOutUserStatusSubject.asObserver(),
            settingChange: settingChangeSubject
        )
        
        logOutUserTapSubject
            .subscribe(onNext: { [weak self] in
                self?.webasyst.logOutUser { [weak self] logout in
                    guard let self = self else { return }
                    self.logOutUserStatusSubject.onNext(logout)
                }
            }).disposed(by: disposeBag)
        
        changeActiveSettingSubject
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] install in
                UserDefaults.setCurrentInstall(withValue: install.id)
                UserDefaults.standard.setValue(true, forKey: "switchAcc")
                AnalyticsManager.setupAuthorizedKeys()
                if UserDefaults.standard.synchronize() {
                    self?.setNewCounts(setSelected: install.name)
                    self?.settingChangeSubject.accept(true)
                }
            }).disposed(by: disposeBag)
        
        fetchInstallList(withInstallsUpdate: withInstallsUpdate)
        getUserData()
        
        refreshProfile
            .share()
            .subscribe { [weak self] _ in
                self?.getUserData()
            }.disposed(by: disposeBag)
    }
    
    private func fetchInstallList(withInstallsUpdate: Bool) {
        let withoutInstalls = { [weak self] in
            DispatchQueue.main.async {
                NotificationCenter.postMessage(.withoutInstalls)
                self?.setWithSelectedCount([])
            }
        }
        
        let currentInstall: String = .currentInstall
        
        webasyst.getAllUserInstall { [weak self] userInstalls in
            guard let self = self else { return }
            if let installs = userInstalls {
                if !installs.isEmpty {
                    self.setWithSelectedCount(installs)
                }  else {
                    withoutInstalls()
                }
            }
        }
        if withInstallsUpdate {
            webasyst.updateUserInstalls { [weak self] installs in
                guard let self = self else { return }
                if let installs = installs {
                    if installs.count == 0 {
                        self.callCoordinatorComplitionSubject.onNext(false)
                        withoutInstalls()
                    } else {
                        webasyst.getAllUserInstall { [weak self] userInstalls in
                            guard let self = self else { return }
                            if let installs = userInstalls, !installs.isEmpty {
                                DispatchQueue.main.async {
                                    self.setWithSelectedCount(installs)
                                    if currentInstall != .currentInstall {
                                        self.setNewCounts(setSelected: installs.first(where: { $0.id == .currentInstall })?.name)
                                        self.callCoordinatorComplitionSubject.onNext(true)
                                    }
                                }
                            } else {
                                withoutInstalls()
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func setWithSelectedCount(_ installs: [UserInstall]) {
            do {
                let url = WebasystApp.url()
                let object = try Data(contentsOf: url)
                guard let decodedInstall = try NSKeyedUnarchiver.unarchivedObject(ofClass: NSDictionary.self, from: object) as? Dictionary<String?, SettingsListModel>, !object.isEmpty else { return }
                
                if !installs.allSatisfy({
                    guard let name = $0.name else { return true }
                    return decodedInstall.keys.contains(name) }) {
                    createNew(installs: installs)
                }
                
                let sorted = installs.sorted(by: {
                    
                    guard let countFirst = decodedInstall[$0.name]?.countSelected,
                          let countSecond = decodedInstall[$1.name]?.countSelected,
                          let wasSelected = decodedInstall[$0.name]?.isLast else { return false }
                    
                    if wasSelected {
                        return true
                    } else if countFirst > countSecond && !wasSelected {
                        return true
                    } else {
                        return false
                    }
                    
                })
                
                self.settingsListSubject.onNext(sorted)
            } catch { createNew(installs: installs) }
    }
    
    private func createNew(installs: [UserInstall]) {
        var dictionary = Dictionary<String?, SettingsListModel>()
        installs.forEach {
            dictionary[$0.name] = SettingsListModel(countSelected: 0, isLast: false, name: $0.name ?? "", url: $0.url)
        }
        do {
            let url = WebasystApp.url()
            let encodedData = try NSKeyedArchiver.archivedData(withRootObject: dictionary, requiringSecureCoding: false)
            try encodedData.write(to: url)
        } catch { print(error) }
        self.settingsListSubject.onNext(installs)
    }
    
    func setNewCounts(setSelected: String?) {
            if let setSelected = setSelected {
            do {
                let url = WebasystApp.url()
                let object = try Data(contentsOf: url)
                guard let decodedInstall = try NSKeyedUnarchiver.unarchivedObject(ofClass: NSDictionary.self, from: object) as? Dictionary<String?, SettingsListModel> else { return }
                decodedInstall.values.forEach { $0.isLast = false }
                decodedInstall[setSelected]?.isLast = true
                decodedInstall[setSelected]?.countSelected += 1
                let encodedData = try NSKeyedArchiver.archivedData(withRootObject: decodedInstall, requiringSecureCoding: false)
                try encodedData.write(to: url)
            } catch {
                print(error)
            }
        }
    }
    
    public func getUserData() {
        if let profile = webasyst.getProfileData() {
            self.userProfileDataSubject.onNext(profile)
        }
    }
    
}

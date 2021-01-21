//
//  ProfileViewModel.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 1/20/21.
//

import Foundation
import RxSwift

protocol ProfileViewModelProtocol {
    var title: String { get }
    init(coordinator: ProfileCoordinatorProtocol, profileDataService: ProfileDataServiceProtocol)
    func getUserData() -> Observable<ProfileData>
    func exitAccount()
}

class ProfileViewModel: ProfileViewModelProtocol {
    
    var title: String = "Профиль"
    private var coordinator: ProfileCoordinatorProtocol
    private var profileDataService: ProfileDataProtocol
    
    required init(coordinator: ProfileCoordinatorProtocol, profileDataService: ProfileDataServiceProtocol) {
        self.coordinator = coordinator
        self.profileDataService = profileDataService
    }
    
    func getUserData() -> Observable<ProfileData> {
        self.profileDataService.getUserData().map { $0 }
    }
    
    func exitAccount() {
        let profileDataService = ProfileDataService()
        profileDataService.deleteProfileData()
        let profileInstallListService = ProfileInstallListService()
        profileInstallListService.deleteAllList()
        KeychainManager.deleteAllKeys()
        let window = UIApplication.shared.windows.first ?? UIWindow()
        let appCoordinator = AppCoordinator(window: window)
        appCoordinator.start()
    }
    
}

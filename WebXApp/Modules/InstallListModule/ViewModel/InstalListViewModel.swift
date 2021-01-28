//
//  InstalListViewModel.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 1/18/21.
//

import Foundation
import RxSwift
import RxCocoa

protocol InstallListViewModelProtocol {
    var installList: [ProfileInstallList] { get }
    var dataSource: BehaviorRelay<Result<[ProfileInstallList]>> { get }
    var title: String { get }
    init(profileInstallListService: ProfileInstallListServiceProtocol, coordinator: InstallListCoordinatorProtocol, profileDataService: ProfileDataServiceProtocol)
    func fetchInstallList()
    func selectDomainUser(_ index: Int)
    func getUserData() -> Observable<ProfileData>
    func sinOutAccount()
}

final class InstallListViewModel: InstallListViewModelProtocol {
    
    let title = NSLocalizedString("profileTitle", comment: "")
    let disposeBag = DisposeBag()
    
    var installList: [ProfileInstallList] = []
    var dataSource = BehaviorRelay(value: Result<[ProfileInstallList]>.Success([]))
    private var profileInstallListService: ProfileInstallListServiceProtocol
    var coordinator: InstallListCoordinatorProtocol
    private var profileDataService: ProfileDataProtocol
    
    required init(profileInstallListService: ProfileInstallListServiceProtocol, coordinator: InstallListCoordinatorProtocol, profileDataService: ProfileDataServiceProtocol) {
        self.profileInstallListService = profileInstallListService
        self.coordinator = coordinator
        self.profileDataService = profileDataService
        fetchInstallList()
    }
    
    func fetchInstallList() {
        self.profileInstallListService.getInstallList()
            .bind { (result) in
                switch result {
                case .Success(let install):
                    self.installList = install
                    self.dataSource.accept(Result.Success(install))
                case .Failure(_):
                    self.dataSource.accept(Result.Failure(.notEntity))
                }
            }.disposed(by: disposeBag)
    }
    
    func selectDomainUser(_ index: Int) {
        UserDefaults.standard.setValue(self.installList[index].domain, forKey: "selectDomainUser")
        let nc = NotificationCenter.default
        nc.post(name: Notification.Name("ChangedSelectDomain"), object: nil)
        self.coordinator.dismissInstallList()
    }
    
    func getUserData() -> Observable<ProfileData> {
        self.profileDataService.getUserData().map { $0 }
    }
    
    func sinOutAccount() {
        WebasystUserNetworkingService().singUpUser { (success) in
            if success {
                let profileDataService = ProfileDataService()
                profileDataService.deleteProfileData()
                let profileInstallListService = ProfileInstallListService()
                profileInstallListService.deleteAllList()
                KeychainManager.deleteAllKeys()
                let domain = Bundle.main.bundleIdentifier!
                UserDefaults.standard.removePersistentDomain(forName: domain)
                UserDefaults.standard.synchronize()
                let window = UIApplication.shared.windows.first ?? UIWindow()
                let appCoordinator = AppCoordinator(window: window)
                appCoordinator.start()
            }
        }
    }
    
}

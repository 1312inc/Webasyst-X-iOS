//
//  InstalListViewModel.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 1/18/21.
//

import Foundation
import RxSwift
import RxCocoa
import Webasyst

protocol InstallListViewModelProtocol {
    var installList: [UserInstall] { get }
    var dataSource: BehaviorRelay<Result<[UserInstall]>> { get }
    var title: String { get }
    init(coordinator: InstallListCoordinatorProtocol)
    func fetchInstallList()
    func selectDomainUser(_ index: Int)
    func getUserData() -> Observable<ProfileData>
    func sinOutAccount()
}

final class InstallListViewModel: InstallListViewModelProtocol {
    
    let title = NSLocalizedString("profileTitle", comment: "")
    let disposeBag = DisposeBag()
    
    var installList: [UserInstall] = []
    var dataSource = BehaviorRelay(value: Result<[UserInstall]>.Success([]))
    var coordinator: InstallListCoordinatorProtocol
    private var webasyst = WebasystApp()
    
    required init(coordinator: InstallListCoordinatorProtocol) {
        self.coordinator = coordinator
        fetchInstallList()
    }
    
    func fetchInstallList() {
        webasyst.getAllUserInstall { userInstalls in
            guard let installs = userInstalls else {
                self.dataSource.accept(Result.Failure(.notEntity))
                return
            }
            self.installList = installs
            self.dataSource.accept(Result.Success(installs))
        }
    }
    
    func selectDomainUser(_ index: Int) {
        UserDefaults.standard.setValue(self.installList[index].id, forKey: "selectDomainUser")
        let nc = NotificationCenter.default
        nc.post(name: Notification.Name("ChangedSelectDomain"), object: nil)
        self.coordinator.dismissInstallList()
    }
    
    func getUserData() -> Observable<ProfileData> {
        return Observable.create { observer in
            let profileData = self.webasyst.getProfileData()
            if let profile = profileData {
                observer.onNext(profile)
            }
            
            return Disposables.create {
                
            }
        }
    }
    
    func sinOutAccount() {
        webasyst.logOutUser { result in
            if result {
                DispatchQueue.main.async {
                    let window = UIApplication.shared.windows.first ?? UIWindow()
                    let appCoordinator = AppCoordinator(window: window)
                    appCoordinator.start()
                }
            }
        }
    }
    
}

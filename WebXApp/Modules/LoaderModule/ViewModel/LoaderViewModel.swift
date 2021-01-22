//
//  LoaderViewModel.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 1/22/21.
//

import Foundation
import RxSwift

protocol LoaderViewModelProtocol: class {
    var userName: String { get }
    init(networkingManager: WebasystUserNetworkingServiceProtocol, coordinator: LoaderCoordinatorProtocol)
    func fetchLoadUserData() -> Observable<(String, Int)>
}

class LoaderViewModel: LoaderViewModelProtocol {
    
    
    private var networkingManager: WebasystUserNetworkingServiceProtocol
    private var coordinator: LoaderCoordinatorProtocol
    var userName: String = UserDefaults.standard.string(forKey: "userName") ?? ""
    
    required init(networkingManager: WebasystUserNetworkingServiceProtocol, coordinator: LoaderCoordinatorProtocol) {
        self.networkingManager = networkingManager
        self.coordinator = coordinator
        loadUserProfileData()
    }
    
    func fetchLoadUserData() -> Observable<(String, Int)> {
        return Observable.create { (observer) -> Disposable in
            self.networkingManager.preloadUserData().subscribe { (result) in
                observer.onNext((result.0, result.1))
            } onError: { (error) in
                print(error)
            } onCompleted: {
                DispatchQueue.main.async {
                    self.coordinator.successLoad()
                }
            } onDisposed: {
                
            }
        }
    }
    
    func loadUserProfileData() {
        self.networkingManager.getUserData()
    }

}

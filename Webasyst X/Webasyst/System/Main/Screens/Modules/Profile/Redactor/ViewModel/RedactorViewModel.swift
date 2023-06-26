//
//  RedactorViewModel.swift
//  Shop-Script
//
//  Created by Леонид Лукашевич on 18.10.2022.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit
import Webasyst

//MARK: RedactorViewModel
final class RedactorViewModel: WebasystViewModelType {
    
    let input: Input
    
    struct Input {
        let updateNeeded: PublishRelay<RedactorUpdate>
    }
    
    let output: Output
    
    struct Output {
        let sucessfullyUpdated: PublishRelay<Swift.Result<RedactorUpdate, Error>>
        let userProfileData: PublishRelay<ProfileData>
    }
    
    private var disposeBag = DisposeBag()
    private let webasyst = WebasystApp()
    
    //MARK: Input Objects
    private let updateNeeded = PublishRelay<RedactorUpdate>()
    //MARK: Output Objects
    private let sucessfullyUpdated = PublishRelay<Swift.Result<RedactorUpdate, Error>>()
    private let userProfileData = PublishRelay<ProfileData>()
    
    init() {
        
        //Init input property
        self.input = Input(updateNeeded: updateNeeded)
        
        //Init output property
        self.output = Output(
            sucessfullyUpdated: sucessfullyUpdated,
            userProfileData: userProfileData
        )
        
        updateNeeded.share().subscribe { [weak self] in
            guard let self = self else { return }
            guard Reachability.isConnectedToNetwork() else {
                self.sucessfullyUpdated.accept(.failure(ServerError.requestFailed(text: "Connection error")))
                return
            }
            switch $0.element {
            case .profile(let profile):
                self.editProfile(profile)
            case .image(let image):
                self.uploadImage(image)
            case .remove:
                self.remove()
            case .delete:
                self.delete()
            case .none:
                break
            }
        }.disposed(by: disposeBag)
    }
    
    fileprivate func editProfile(_ profile: ProfileData) {
        webasyst.changeCurrentUserData(profile: profile) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let profile):
                self.sucessfullyUpdated.accept(.success(.profile(profile)))
            case .failure(let error):
                self.sucessfullyUpdated.accept(.failure(error))
            }
        }
    }
    
    fileprivate func remove() {
        webasyst.deleteUserImage { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.sucessfullyUpdated.accept(.success(.remove))
            case .failure(let error):
                self.sucessfullyUpdated.accept(.failure(error))
            }
        }
    }
    
    fileprivate func uploadImage(_ image: UIImage) {
        let resizedImage = image.resizeToMax(1312)
        webasyst.updateUserImage(resizedImage) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.sucessfullyUpdated.accept(.success(.image(resizedImage.imageResize(sizeChange: CGSize(width: 1312, height: 1312))!)))
            case .failure(let error):
                self.sucessfullyUpdated.accept(.failure(error))
            }
        }
    }
    
    fileprivate func delete() {
        webasyst.deleteAccount(completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.sucessfullyUpdated.accept(.success(.delete(true)))
            case .failure:
                self.sucessfullyUpdated.accept(.success(.delete(false)))
            }
        })
    }
    
    public func getUserData() {
        if let profile = webasyst.getProfileData() {
            self.userProfileData.accept(profile)
        }
    }
    
}

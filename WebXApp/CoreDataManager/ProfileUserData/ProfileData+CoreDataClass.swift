//
//  ProfileData+CoreDataClass.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 1/20/21.
//
//

import Foundation
import CoreData
import RxSwift

protocol ProfileDataProtocol {
    func saveProfileData(_ user: UserData, avatar: Data)
    func getUserData() ->  Observable<ProfileData>
}

@objc(ProfileData)
public class ProfileData: NSManagedObject, ProfileDataProtocol {
    
    func saveProfileData(_ user: UserData, avatar: Data) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ProfileData")
        request.predicate = NSPredicate(format: "email == %@", user.email[0].value)
        
        do {
            guard let result = try context.fetch(request) as? [ProfileData] else {
                return
            }
            if result.isEmpty {
                let profile = NSEntityDescription.insertNewObject(forEntityName: "ProfileData", into: context) as! ProfileData
                profile.firstName = user.firstname
                profile.lastName = user.lastname
                profile.middleName = user.middlename
                profile.email = user.email[0].value
                profile.userPic = avatar
                appDelegate.saveContext()
            } else {
                result[0].firstName = user.firstname
                result[0].lastName = user.lastname
                result[0].middleName = user.middlename
                result[0].userPic = avatar
                appDelegate.saveContext()
            }
        } catch { }
        
    }
    
    func getUserData() ->  Observable<ProfileData> {
        
        return Observable.create { (observer) -> Disposable in
            
            guard let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else {
                observer.onError(NSError(domain: "getUserData Core Data context error", code: -1, userInfo: nil))
                return Disposables.create {}
            }
            
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ProfileData")
            do {
                if let result = try context.fetch(request) as? [ProfileData] {
                    observer.onNext(result[0])
                    observer.onCompleted()
                    return Disposables.create {}
                }
            } catch {
                observer.onError(NSError(domain: "getUserData Core Data request error", code: -1, userInfo: nil))
                return Disposables.create {}
            }
            
            return Disposables.create { }
            
        }.asObservable()
        
    }
    
}

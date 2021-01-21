//
//  ProfileInstallList+CoreDataClass.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 1/20/21.
//
//

import Foundation
import CoreData
import RxSwift

typealias ProfileInstallListServiceProtocol = ProfileInstallListProtocol
typealias ProfileInstallListService = ProfileInstallList

protocol ProfileInstallListProtocol {
    func saveInstall(_ installList: InstallList, accessToken: String)
    func getInstallList() -> Observable<[ProfileInstallList]>
    func deleteAllList()
    func getTokenActiveInstall(_ domain: String) -> String
}

@objc(ProfileInstallList)
public class ProfileInstallList: NSManagedObject, ProfileInstallListServiceProtocol {
    
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    private lazy var context = appDelegate.persistentContainer.viewContext
    
    func saveInstall(_ installList: InstallList, accessToken: String) {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ProfileInstallList")
        request.predicate = NSPredicate(format: "clientId == %@", installList.id)
        do {
            guard let result = try context.fetch(request) as? [ProfileInstallList] else {
                print("ProfileInstallList request error")
                return
            }
            if result.isEmpty {
                let install = NSEntityDescription.insertNewObject(forEntityName: "ProfileInstallList", into: context) as! ProfileInstallList
                install.clientId = installList.id
                install.domain = installList.domain
                install.url = installList.url
                install.accessToken = accessToken
                appDelegate.saveContext()
            }
        } catch { }
    }
    
    func getInstallList() -> Observable<[ProfileInstallList]> {
        return Observable.create { (observer) -> Disposable in
            
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ProfileInstallList")
            
            do {
                if let result = try self.context.fetch(request) as? [ProfileInstallList] {
                    observer.onNext(result)
                    observer.onCompleted()
                }
            } catch {
                observer.onError(NSError(domain: "getInstallList Core Data request error", code: -1, userInfo: nil))
                return Disposables.create {}
            }
            return Disposables.create { }
            
        }.asObservable()
    }
    
    func deleteAllList() {
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "ProfileInstallList")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print ("There was an error")
        }
    }
    
    func getTokenActiveInstall(_ domain: String) -> String {
        var returnToken = ""
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ProfileInstallList")
        request.predicate = NSPredicate(format: "domain == %@", domain)
        
        do {
            if let result = try self.context.fetch(request) as? [ProfileInstallList] {
                returnToken = result.first?.accessToken ?? ""
            }
        } catch {
            print ("There was an error")
        }
        
        return returnToken
    }
    
}

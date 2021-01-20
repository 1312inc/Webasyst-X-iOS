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

protocol ProfileInstallListProtocol {
    func saveInstall(_ installList: ) 
}

@objc(ProfileInstallList)
public class ProfileInstallList: NSManagedObject {

}

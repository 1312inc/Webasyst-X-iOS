//
//  ProfileInstallList+CoreDataProperties.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 1/20/21.
//
//

import Foundation
import CoreData


extension ProfileInstallList {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ProfileInstallList> {
        return NSFetchRequest<ProfileInstallList>(entityName: "ProfileInstallList")
    }

    @NSManaged public var accessToken: String?
    @NSManaged public var clientId: String?
    @NSManaged public var domain: String?
    @NSManaged public var url: String?

}

extension ProfileInstallList : Identifiable {

}

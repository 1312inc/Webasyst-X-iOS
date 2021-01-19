//
//  InstallUser+CoreDataProperties.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 1/19/21.
//
//

import Foundation
import CoreData


extension InstallUser {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<InstallUser> {
        return NSFetchRequest<InstallUser>(entityName: "InstallUser")
    }

    @NSManaged public var url: String?
    @NSManaged public var domain: String?
    @NSManaged public var clientId: String?
    @NSManaged public var accessToken: String?

}

extension InstallUser : Identifiable {

}

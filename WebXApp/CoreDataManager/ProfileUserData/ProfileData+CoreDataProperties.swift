//
//  ProfileData+CoreDataProperties.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 1/20/21.
//
//

import Foundation
import CoreData


extension ProfileData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ProfileData> {
        return NSFetchRequest<ProfileData>(entityName: "ProfileData")
    }

    @NSManaged public var email: String?
    @NSManaged public var firstName: String?
    @NSManaged public var lastName: String?
    @NSManaged public var middleName: String?
    @NSManaged public var userPic: Data?

}

extension ProfileData : Identifiable {

}

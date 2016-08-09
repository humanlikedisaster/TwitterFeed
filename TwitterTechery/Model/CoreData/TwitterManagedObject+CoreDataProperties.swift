//
//  TwitterManagedObject+CoreDataProperties.swift
//  TwitterTechery
//
//  Created by hereiam on 09.08.16.
//  Copyright © 2016 Techery. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension TwitterManagedObject {

    @NSManaged var created_at: NSDate?
    @NSManaged var follows: NSNumber?
    @NSManaged var id: String?
    @NSManaged var retweets: NSNumber?
    @NSManaged var text: String?
    @NSManaged var userName: String?
    @NSManaged var userScreenName: String?
    @NSManaged var imageURL: String?

}

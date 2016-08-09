//
//  CoreDataManager.swift
//  TwitterTechery
//
//  Created by hereiam on 27.07.16.
//  Copyright © 2016 Techery. All rights reserved.
//

import UIKit
import CoreData

class CoreDataManager {
    static let sharedInstance = CoreDataManager()

    init() {
    }
    
    lazy var posts: [TwitterManagedObject] = {
        let managedContext = self.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "TwitterManagedObject")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "created_at", ascending: false)]
        do
        {
            let results = try managedContext.executeFetchRequest(fetchRequest)
            return results as! [TwitterManagedObject]
        }
        catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        catch
        {
        }
        return []
    }()
    
    func syncTweet(tweetViewModel: TweetViewModel)
    {
        let managedContext = self.managedObjectContext
        if let index = self.posts.indexOf({$0.id == tweetViewModel.entity.id})
        {
            let twitterManagedObject = posts[index]
            twitterManagedObject.setupWithTweetViewModel(tweetViewModel)
        }
        else
        {
            let twitterManagedObject = TwitterManagedObject(context: managedContext)
            twitterManagedObject.setupWithTweetViewModel(tweetViewModel)
        }
        do
        {
            try managedContext.save()
        }
        catch _
        {
        }
    }

    lazy var applicationDocumentsDirectory: NSURL =
    {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel =
    {
        let modelURL = NSBundle.mainBundle().URLForResource("TwitterTechery", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {

        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason

            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
}

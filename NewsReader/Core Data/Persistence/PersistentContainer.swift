//
//  PersistentContainer.swift
//  NewsReader
//
//  Created by Vigneswaran on 13/02/25.
//

import Foundation
import CoreData

final class PersistentContainer: NSPersistentContainer {

    static func getSharedInstance() -> PersistentContainer {
        queue.sync {
            if shared == nil {
                shared = PersistentContainer(name: "NewsReader")
            }
            return shared!
        }
    }
    
    private static let queue = DispatchQueue(label: "persistentContainer")
    static var shared: PersistentContainer?
    
    static let databaseURL = AppDirectories.documentsDirectoryUrl.appendingPathComponent("NewsReader.sqlite")
    
    func setup() {
        let description = NSPersistentStoreDescription(url: PersistentContainer.databaseURL)
        description.shouldMigrateStoreAutomatically = true
        description.shouldAddStoreAsynchronously = false
        description.shouldInferMappingModelAutomatically = true
        persistentStoreDescriptions = [description]

        loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            } else {
                
            }
        })

        viewContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        viewContext.automaticallyMergesChangesFromParent = true
    }
    
    override func newBackgroundContext() -> NSManagedObjectContext {
        let context = super.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        context.automaticallyMergesChangesFromParent = true
        return context
    }
}

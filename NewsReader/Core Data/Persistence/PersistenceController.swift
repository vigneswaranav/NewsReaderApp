//
//  Persistence.swift
//  NewsReader
//
//  Created by Vigneswaran on 13/02/25.
//

import Foundation
import CoreData

class PersistenceController {
    
    enum ContextProcessPriority: CaseIterable {
        case main
        case userInitiated
        case userInteractive
        case `default`
        case backgroundSave
        case low
        case createNew
        case indexing
        
        func mainType() -> ContextProcessPriority {
            if self == .userInitiated || self == .userInteractive {
                return .userInitiated
            }
            if self == .createNew {
                return .createNew
            }
            return .default
        }
        
        var isUserContext: Bool {
            switch self {
            case .userInitiated, .userInteractive:
                return true
            default:
                return false
            }
        }
    }
    
    static let processingGroup = DispatchGroup()
    let databaseSavingSerialQueue: DispatchQueue = DispatchQueue(label: "com.zoho.cliq.db.save.root", attributes: DispatchQueue.Attributes.concurrent)
    
    var processingContexts: SynchronizedDictionary<ContextProcessPriority, NSManagedObjectContext> = SynchronizedDictionary(dictionary: [:])
    
    internal static var shared: PersistenceController = {
        let handler = PersistenceController()
        return handler
    }()
    
    init() {
        _ = self.mainThreadManagedObjectContext
    }
    
    let parentContextName = "parent_context"
    
    static var mainContext: NSManagedObjectContext!
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let persistentContainer = PersistentContainer.getSharedInstance()
        persistentContainer.setup()
        return persistentContainer
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
    }()
    
    func contextForThread() -> NSManagedObjectContext? {
        if Thread.isMainThread {
            return PersistenceController.mainContext
        }
        return contextFor(priority: ContextProcessPriority.userInitiated)
    }
    
    func contextFor(priority: ContextProcessPriority) -> NSManagedObjectContext? {
        if priority == .main {
            if let context = PersistenceController.mainContext {
                return context
            } else {
                return nil
            }
        }
        guard let parent = PersistenceController.mainContext else {
            return nil
        }
        if let context = processingContexts[priority.mainType()] {
            return context
        } else {
            let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            context.automaticallyMergesChangesFromParent = true
            context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
            context.parent = parent
            if context.persistentStoreCoordinator == nil {
                context.persistentStoreCoordinator = parent.persistentStoreCoordinator
            }
            processingContexts[priority.mainType()] = context
            return context
        }
    }
    
    @objc func resetAllHandlers() {
        self.processingContexts.removeAll()
        NotificationCenter.default.removeObserver(self)
    }
    
    func initiateDataBase() {
        self.addPersistantStoreIfNeeded()
        if PersistenceController.shared.mainThreadManagedObjectContext == nil {
            mainThreadManagedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            mainThreadManagedObjectContext?.name = self.parentContextName
            mainThreadManagedObjectContext?.persistentStoreCoordinator = persistentContainer.persistentStoreCoordinator

            mainThreadManagedObjectContext?.automaticallyMergesChangesFromParent = true
            mainThreadManagedObjectContext?.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
            PersistenceController.mainContext = self.mainThreadManagedObjectContext
        }
    }
    
    func addPersistantStoreIfNeeded() {
        let stores = persistentContainer.persistentStoreCoordinator.persistentStores
        if stores.isEmpty {
            addNewPersistantStore(in: persistentContainer,
                                    at: PersistentContainer.databaseURL)
        }
    }
    
    func resetDatabase() {
        guard let storeURL = persistentContainer.persistentStoreCoordinator.persistentStores.first?.url else {
            return
        }
        PersistenceController.mainContext.performAndWait {
            PersistenceController.mainContext.reset()
            self.destroyAndCreatePersitentStore(storeURL: storeURL)
            PersistenceController.shared.mainThreadManagedObjectContext = nil
        }
    }
    
    private func destroyAndCreatePersitentStore(storeURL: URL) {
        self.persistentContainer.persistentStoreCoordinator.performAndWait {
            do {
                try self.persistentContainer.persistentStoreCoordinator.destroyPersistentStore(at: storeURL, ofType: NSSQLiteStoreType, options: nil)
                try self.persistentContainer.persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL)
            } catch {
                print(error)
            }
        }
    }
    
    private func addNewPersistantStore(in container: NSPersistentContainer, at url: URL) {
        let coordinator = container.persistentStoreCoordinator
        coordinator.performAndWait {
            do {
                try container.persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType,
                                                                            configurationName: nil,
                                                                            at: url)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    private var mainThreadManagedObjectContext: NSManagedObjectContext? {
        didSet {
            if mainThreadManagedObjectContext == nil {
                PersistenceController.mainContext = nil
            }
        }
    }
    
    func dispatchOnSerialThreadWithContext(priority: ContextProcessPriority = ContextProcessPriority.default, _ block: @escaping (NSManagedObjectContext)->()) {
        Self.processingGroup.enter()
        guard let context = self.contextFor(priority: priority) else {
            Self.processingGroup.leave()
            return
        }
        context.perform {
            block(context)
            Self.processingGroup.leave()
        }
    }
    
}

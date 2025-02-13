//
//  DatabaseHandler.swift
//  NewsReader
//
//  Created by Vigneswaran on 13/02/25.
//

import Foundation
import CoreData

protocol DatabaseHandler: EntityModelMapperProtocol {
    var entityName: String { get }
    var defaultPredicate: NSPredicate { get }
    var uniqueIdName: String { get }
    var listSortedKeys: [[String:Any]] { get }
}

extension DatabaseHandler {
    
    var entityName: String {
        return String(describing: Entity.self)
    }
    
    var defaultPredicate: NSPredicate {
        return NSPredicate(format: "\(uniqueIdName) != nil")
    }
    
    func getFetchResultController(_ predicate: NSPredicate?,
                                  sectionKeyPath: String? = nil,
                                  sortedKeys: [[String:Any]]? = nil,
                                  delegate: NSFetchedResultsControllerDelegate?,
                                  limit: Int? = 0,
                                  context: NSManagedObjectContext) -> NSFetchedResultsController<NSFetchRequestResult> {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
        fetchRequest.includesPendingChanges = true
        
        fetchRequest.fetchBatchSize = 20
        if limit != nil {
            fetchRequest.fetchLimit = limit!
        }
        
        fetchRequest.sortDescriptors = getSortDescriptors(sortedKeys)
        fetchRequest.predicate = predicate
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                          managedObjectContext: context,
                                                          sectionNameKeyPath: sectionKeyPath,
                                                          cacheName: nil)
        controller.delegate = delegate
        do {
            try controller.performFetch()
        } catch  {
            print(error)
         }
        return controller
    }
    
    func getAllObjects(predicate: NSPredicate, sortDesc: [NSSortDescriptor], limit:Int? = nil, context: NSManagedObjectContext) -> [Any]? {
        return executeFetchRequest(getFetchRequestForPredicate(predicate: predicate, limit: limit, sort: sortDesc), context: context)
    }
    
    func executeFetchRequest(_ request : NSFetchRequest<NSFetchRequestResult>, async: Bool = false, dItem: DispatchWorkItem? = nil, context : NSManagedObjectContext) -> [Any]? {
        if async == true {
            return executeAsyncFetchRequest(request, dItem: dItem, context: context)
        }
        func objects() -> [Any]? {
            var objects : [Any]?
            do {
                objects = try context.fetch(request)
            } catch _ {
            }
            return objects
        }
        if context.concurrencyType == .mainQueueConcurrencyType {
            var objs: [Any]?
            context.performAndWait {
                objs = objects()
            }
            return objs
        }
        return objects()
    }
    
    func getSingleObject(id: String?, context: NSManagedObjectContext?) -> NSManagedObject? {
        if context != nil {
            var object: NSManagedObject?
            let request = self.getFetchRequest(uniqueId: (id == nil) ? nil : [id!])
            request.fetchLimit = 1
            let objects = self.executeFetchRequest(request, context: context!)
            object = objects?.first as? NSManagedObject
            return object
        }
        return nil
    }
    
    func getFetchRequestForPredicate(predicate: NSPredicate?, limit: Int? = nil, sort: [NSSortDescriptor]? = nil, propertiesToFetch: [String]? = nil) -> NSFetchRequest<NSFetchRequestResult> {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
        fetchRequest.predicate = predicate
        if let limit {
            fetchRequest.fetchLimit = limit
        }
        if let sort {
            fetchRequest.sortDescriptors = sort
        }
        if let propertiesToFetch {
            fetchRequest.propertiesToFetch = propertiesToFetch
            fetchRequest.resultType = .dictionaryResultType
        }
        return fetchRequest
    }
    
    func getFetchRequest(uniqueId: [String]?, sort: Bool = false) -> NSFetchRequest<NSFetchRequestResult> {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
        fetchRequest.includesPendingChanges = true
        if let ids = uniqueId {
            fetchRequest.fetchLimit = uniqueId!.count
            if ids.count == 1 {
                fetchRequest.predicate = NSPredicate(format: "%K == %@",uniqueIdName, ids[0])
            }
            else {
                fetchRequest.predicate = NSPredicate(format: "%K IN %@",uniqueIdName, ids)
            }
        }
        if sort == true {
            fetchRequest.sortDescriptors = self.getSortDescriptors()
        }
        return fetchRequest
    }
    
    func getSortDescriptors(_ sortedKeys: [[String:Any]]? = nil) -> [NSSortDescriptor]  {
        var sortDescriptors : [NSSortDescriptor] = [NSSortDescriptor]()
        for sortKey in sortedKeys ?? listSortedKeys {
            if let type = sortKey["type"] as? Int {
                if type == 0 {//String
                    sortDescriptors.append(NSSortDescriptor(key: sortKey["value"] as? String, ascending: (sortKey["sort"] == nil) ? true : sortKey["sort"] as! Bool, selector: #selector(NSString.caseInsensitiveCompare(_:))))
                }else {
                    sortDescriptors.append(NSSortDescriptor(key: sortKey["value"] as? String, ascending: sortKey["sort"] as! Bool))
                }
            }
        }
        return sortDescriptors
    }
    
    func createNewObject(id: String, context: NSManagedObjectContext) -> NSManagedObject {
        let entity = NSEntityDescription.insertNewObject(forEntityName: entityName, into: context)
        entity.setValue(id, forKey: uniqueIdName)
        do {
            try context.obtainPermanentIDs(for: [entity])
        } catch _ {
        }
        return entity
    }
    
    func getAllObjectForPredicate(predicate: NSPredicate?,properties:[String]? = nil, context: NSManagedObjectContext) -> [Any]? {
        return executeFetchRequest(getFetchRequestForPredicate(predicate:predicate, limit: nil, sort: nil, propertiesToFetch:properties ), context: context)
    }
    
    func executeAsyncFetchRequest(_ request : NSFetchRequest<NSFetchRequestResult>, dItem: DispatchWorkItem? = nil, context : NSManagedObjectContext) -> [AnyObject]? {
        var objects : [AnyObject]?
        let group = DispatchGroup()
        group.enter()
        let asynchronousFetchRequest = NSAsynchronousFetchRequest(fetchRequest: request) { asynchronousFetchResult in
            
            // Retrieves an array of dogs from the fetch result `finalResult`
            guard let result = asynchronousFetchResult.finalResult else {
                group.leave()
                return
            }
            objects = result
            group.leave()
        }
        context.perform {
            do {
                // Executes `asynchronousFetchRequest`
                if dItem?.isCancelled == true {
                    group.leave()
                }
                else {
                    try context.execute(asynchronousFetchRequest)
                }
            } catch let error {
                group.leave()
                print("NSAsynchronousFetchRequest error: \(error)")
            }
        }
        group.wait()
        return objects
    }
    
    func dropAllRecords(context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: self.entityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try context.execute(deleteRequest)
        } catch let error as NSError {
            print(#file, #function, #line, "\(error.localizedDescription)")
        }
    }
    
}


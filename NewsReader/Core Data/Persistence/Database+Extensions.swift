//
//  Database+Extensions.swift
//  NewsReader
//
//  Created by Vigneswaran on 13/02/25.
//

public typealias CompletionBlock = () -> Void

import CoreData
import Foundation

extension NSManagedObjectContext {
    
    func contextObject<T: NSManagedObject>(_ object: T?) -> T? {
        guard let obj = object else {
            return nil
        }
        let newObj = self.object(with: obj.objectID) as? T
        return newObj
    }
    
    func saveContext(_ databaseSavingSerialQueue: DispatchQueue = PersistenceController.shared.databaseSavingSerialQueue, completion: CompletionBlock? = nil, caller: String = #function) {
        
        var parentC: Bool = false
        defer {
            if parentC == false {
                databaseSavingSerialQueue.async {
                    completion?()
                }
            }
        }
        if self.hasChanges {
            do {
                print("c_type: \(concurrencyType), caller: \(caller)")
                try self.save()
                if let root = parent {
                    parentC = true
                    root.perform {
                        root.saveContext(completion: completion, caller: caller)
                    }
                }
            } catch {
                print(error)
            }
        }
    }
    
}

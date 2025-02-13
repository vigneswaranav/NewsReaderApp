//
//  FetchResultControllerObserver.swift
//  NewsReader
//
//  Created by Vigneswaran on 13/02/25.
//

import SwiftUI
import CoreData

class FetchResultControllerObserver<T: DatabaseHandler>: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
    @Published var entities: [T.Entity] = []
    @Published var objects: [T.Model] = []
    
    private let entityHandler: T
    private let context: NSManagedObjectContext
    private let predicate: NSPredicate
    
    private lazy var controller: NSFetchedResultsController<NSFetchRequestResult> = {
        let controller = self.entityHandler.getFetchResultController(self.predicate, delegate: self, context: self.context)
        return controller
    }()
    
    init(entityHandler: T, context: NSManagedObjectContext, predicate: NSPredicate? = nil, sectionNameKeyPath: String? = nil) {
        self.entityHandler = entityHandler
        self.context = context
        self.predicate = predicate ?? entityHandler.defaultPredicate
        super.init()
    }
        
    func fetch() {
        do {
            try self.controller.performFetch()
            self.entities = self.controller.fetchedObjects as? [T.Entity] ?? []
            self.updateModels()
        } catch {
            print("FRC fetch failed with error: \(error)")
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        guard let object = anObject as? T.Entity else { return }
        DispatchQueue.main.async {
            withAnimation {
                switch type {
                case .insert:
                    if let newIndexPath = newIndexPath {
                        if self.entities.count > newIndexPath.row {
                            self.entities.insert(object, at: newIndexPath.row)
                        } else {
                            self.entities.append(object)
                        }
                    }
                case .delete:
                    if let indexPath = indexPath {
                        self.entities.remove(at: indexPath.row)
                    }
                case .update:
                    if let indexPath = indexPath, self.entities.count > indexPath.row {
                        self.entities[indexPath.row] = object
                    }
                case .move:
                    if let indexPath = indexPath, let newIndexPath = newIndexPath {
                        if self.entities.count > indexPath.row {
                            self.entities.remove(at: indexPath.row)
                        }
                        if self.entities.count > newIndexPath.row {
                            self.entities.insert(object, at: newIndexPath.row)
                        } else {
                            self.entities.append(object)
                        }
                    }
                @unknown default:
                    break
                }
            }
            self.updateModels()
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if let updatedObjects = controller.fetchedObjects as? [T.Entity] {
            DispatchQueue.main.async {
                withAnimation {
                    self.entities = updatedObjects
                    self.updateModels()
                }
            }
        }
    }
    
    private func updateModels() {
        self.objects = self.entities.map { self.entityHandler.map(entity: $0) }
    }
}

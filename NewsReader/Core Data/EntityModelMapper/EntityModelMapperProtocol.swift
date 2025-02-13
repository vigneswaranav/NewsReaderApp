//
//  EntityModelMapping.swift
//  NewsReader
//
//  Created by Vigneswaran on 13/02/25.
//

import Foundation
import CoreData

protocol EntityModelMapperProtocol {
    associatedtype Entity: NSManagedObject
    associatedtype Model

    func map(entity: Entity) -> Model
    func reverseMap(model: Model, context: NSManagedObjectContext) -> Entity?
}

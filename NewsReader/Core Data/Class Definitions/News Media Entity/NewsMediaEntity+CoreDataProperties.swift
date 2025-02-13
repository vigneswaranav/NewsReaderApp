//
//  NewsMediaEntity+CoreDataProperties.swift
//  NewsReader
//
//  Created by Vigneswaran on 13/02/25.
//
//

import Foundation
import CoreData


extension NewsMediaEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NewsMediaEntity> {
        return NSFetchRequest<NewsMediaEntity>(entityName: "NewsMediaEntity")
    }

    @NSManaged public var url: String
    @NSManaged public var caption: String?
    @NSManaged public var mediaType: String
    @NSManaged public var type: Int16

}
extension NewsMediaEntity : Identifiable {

}

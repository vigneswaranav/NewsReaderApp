//
//  NewsArticleEntity+CoreDataProperties.swift
//  NewsReader
//
//  Created by Vigneswaran on 13/02/25.
//
//

import Foundation
import CoreData


extension NewsArticleEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NewsArticleEntity> {
        return NSFetchRequest<NewsArticleEntity>(entityName: "NewsArticleEntity")
    }

    @NSManaged public var id: String
    @NSManaged public var publishedDate: Date?
    @NSManaged public var updatedDate: Date?
    @NSManaged public var author: String
    @NSManaged public var title: String
    @NSManaged public var abstract: String
    @NSManaged public var url: String
    @NSManaged public var type: String?
    @NSManaged public var toMedia: Set<NewsMediaEntity>?

}


// MARK: Generated accessors for toMedia
extension NewsArticleEntity {

    @objc(addToMediaObject:)
    @NSManaged public func addToToMedia(_ value: NewsMediaEntity)

    @objc(removeToMediaObject:)
    @NSManaged public func removeFromToMedia(_ value: NewsMediaEntity)

    @objc(addToMedia:)
    @NSManaged public func addToToMedia(_ values: NSSet)

    @objc(removeToMedia:)
    @NSManaged public func removeFromToMedia(_ values: NSSet)

}

extension NewsArticleEntity : Identifiable {

}

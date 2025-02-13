//
//  NewsArticleMediaSyncHandler.swift
//  NewsReader
//
//  Created by Vigneswaran on 13/02/25.
//
import CoreData

class NewsArticleMediaSyncHandler: DatabaseHandler {
    
    typealias Entity = NewsMediaEntity
    typealias Model = NewsArticleMediaItem
    
    var listSortedKeys: [[String : Any]] {
        return []
    }
    
    var uniqueIdName: String {
        return "url"
    }
    
    static let sharedHandler: NewsArticleMediaSyncHandler = {
        let handler = NewsArticleMediaSyncHandler()
        return handler
    }()
    
    func map(entity: NewsMediaEntity) -> NewsArticleMediaItem {
        let mediaType = NewsArticleMediaItem.MediaType(rawValue: entity.mediaType) ?? .image
        let type = NewsArticleMediaItem.Kind(rawValue: Int(entity.type)) ?? .original
        return NewsArticleMediaItem(url: entity.url, caption: entity.caption, type: type, mediaType: mediaType)
    }
    
    func reverseMap(model: NewsArticleMediaItem, context: NSManagedObjectContext) -> NewsMediaEntity? {
        guard let mediaEntity = getSingleObject(id: model.url, context: context) as? NewsMediaEntity ?? createNewObject(id: model.url, context: context) as? NewsMediaEntity else {
            return nil
        }
        mediaEntity.url = model.url
        mediaEntity.caption = model.caption
        mediaEntity.type = Int16(model.type.rawValue)
        mediaEntity.mediaType = model.mediaType.rawValue
        return mediaEntity
    }
}

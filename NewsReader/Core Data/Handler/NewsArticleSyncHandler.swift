//
//  NewsArticleSyncHandler.swift
//  NewsReader
//
//  Created by Vigneswaran on 13/02/25.
//
import Foundation
import CoreData

class NewsArticleSyncHandler: DatabaseHandler {

    typealias Entity = NewsArticleEntity
    typealias Model = NewsArticleItem

    var uniqueIdName: String {
       return "id"
    }
    
    static let sharedHandler: NewsArticleSyncHandler = {
        let handler = NewsArticleSyncHandler()
        return handler
    }()
    
    var listSortedKeys: [[String : Any]] {
        return [["value":"publishedDate", "type": 1, "sort": false], ["value":"updatedDate", "type": 1, "sort": false]]
    }
    
    func saveNewsArticles(_ articles: [NewsArticleItem]) throws {
        PersistenceController.shared.dispatchOnSerialThreadWithContext { [weak self] context in
            guard let self = self else {
                return
            }
            guard let newsArticleEntityList = self.getAllObjects(predicate: NSPredicate(format: "id != nil"), sortDesc: getSortDescriptors(), context: context) as? [NewsArticleEntity] else {
                return
            }
            let availableArticleIds: Set<String> = Set(newsArticleEntityList.compactMap({ $0.id }))
            var currentArticleItemMap: [String: NewsArticleItem] = [:]
            var currentArticleIds: Set<String> = []
            for article in articles {
                let id = String(article.id)
                currentArticleIds.insert(id)
                currentArticleItemMap[id] = article
            }
            let deletedIds = availableArticleIds.subtracting(currentArticleIds)
            let newArticleIds = currentArticleIds.subtracting(availableArticleIds)
            for articleEntity in newsArticleEntityList where deletedIds.contains(articleEntity.id) {
                context.delete(articleEntity)
            }
            for newArticleId in newArticleIds {
                guard let newArticle = currentArticleItemMap[newArticleId] else { continue }
                if let newArticleEntity = self.getSingleObject(id: newArticleId, context: context) as? NewsArticleEntity {
                    self.update(entity: newArticleEntity, with: newArticle)
                } else {
                    guard let newArticleEntity = self.createNewObject(id: newArticleId, context: context) as? NewsArticleEntity else {
                        continue
                    }
                    self.update(entity: newArticleEntity, with: newArticle)
                }
            }
            context.saveContext()
        }
    }
    
    func fetchNewsArticles() async -> [NewsArticleItem] {
        await withCheckedContinuation { continuation in
            PersistenceController.shared.dispatchOnSerialThreadWithContext { context in
                guard let newsArticleEntityList = self.getAllObjects(predicate: NSPredicate(format: "id != nil"), sortDesc: self.getSortDescriptors(), context: context) as? [NewsArticleEntity] else {
                    continuation.resume(returning: [])
                    return
                }
                let articles = newsArticleEntityList.map { (entity) in
                    let article = self.map(entity: entity)
                    return article
                }
                continuation.resume(returning: articles)
            }
        }
    }
        
    private func update(entity: NewsArticleEntity, with article: NewsArticleItem) {
        entity.id = String(article.id)
        entity.title = article.title
        entity.abstract = article.abstract
        entity.publishedDate = article.publishedDate
        entity.updatedDate = article.updatedDate
        entity.author = article.author
        entity.url = article.url
        entity.type = article.type
        for media in article.media {
            guard let context = entity.managedObjectContext, let mediaEntity = NewsArticleMediaSyncHandler.sharedHandler.reverseMap(model: media, context: context) else {
                continue
            }
            entity.addToToMedia(mediaEntity)
        }
    }
        
    func map(entity: NewsArticleEntity) -> NewsArticleItem {
        let mediaList: [NewsArticleMediaItem] = entity.toMedia?.compactMap { item -> NewsArticleMediaItem in
            let newsArticleMediaItem = NewsArticleMediaSyncHandler.sharedHandler.map(entity: item)
            return newsArticleMediaItem
        } ?? []
        return NewsArticleItem(id: Int64(entity.id) ?? 0,
                               title: entity.title,
                               abstract: entity.abstract,
                               publishedDate: entity.publishedDate ?? Date(),
                               updatedDate: entity.updatedDate ?? Date(),
                               author: entity.author,
                               url: entity.url,
                               type: entity.type ?? "Article",
                               media: mediaList)
    }
    
    func reverseMap(model: NewsArticleItem, context: NSManagedObjectContext) -> NewsArticleEntity? {
        guard let entity = getSingleObject(id: String(model.id), context: context) as? NewsArticleEntity ?? createNewObject(id: String(model.id), context: context) as? NewsArticleEntity else {
            return nil
        }
        update(entity: entity, with: model)
        return entity
    }
}

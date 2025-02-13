//
//  NewsArticleRepositoryImpl.swift
//  NewsReader
//
//  Created by Vigneswaran on 13/02/25.
//

import Foundation
import CoreData

class NewsArticleRepositoryImpl: NewsArticleRepositoryProtocol {
    
    private let databaseHandler: NewsArticleSyncHandler
    
    init(databaseHandler: NewsArticleSyncHandler) {
        PersistenceController.shared.initiateDataBase()
        self.databaseHandler = databaseHandler
    }
    
    func fetchLocalArticles() async -> [NewsArticleItem] {
        let articles = await databaseHandler.fetchNewsArticles()
        return articles
    }
    
    func fetchRemoteArticles() async throws -> [NewsArticleItem] {
        let endPoint = Endpoints.mostPopular(section: .viewed, period: .day)
        let result = await APIManager.shared.execute(endPoint, codableTo: NewsArticleResponse<NewsArticleModel>.self)
        switch result {
        case .success(let response):
            let articles = NewsArticleResponseMapper.map(response)
            return articles
        case .failure(let error):
            throw error
        }
    }
    
    func saveArticles(_ articles: [NewsArticleItem]) throws {
        try databaseHandler.saveNewsArticles(articles)
    }
}

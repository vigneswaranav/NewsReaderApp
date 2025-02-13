//
//  FetchMostPopularNewsArticlesUseCase.swift
//  NewsReader
//
//  Created by Vigneswaran on 13/02/25.
//


import Foundation

struct FetchNewsArticleUseCase {
    let repository: NewsArticleRepositoryProtocol
    
    func execute() async -> Result<[NewsArticleItem], Error> {
        do {
            let localArticles = await repository.fetchLocalArticles()
            if !localArticles.isEmpty {
                return .success(localArticles)
            }
            let remoteArticles = try await repository.fetchRemoteArticles()
            try repository.saveArticles(remoteArticles)
            return .success(remoteArticles)
        } catch {
            return .failure(error)
        }
    }
}

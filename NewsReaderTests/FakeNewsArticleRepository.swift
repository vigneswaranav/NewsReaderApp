//
//  FakeNewsArticleRepository.swift
//  NewsReader
//
//  Created by Vigneswaran on 14/02/25.
//


import Foundation
@testable import NewsReader  // Replace with your actual module name

final class FakeNewsArticleRepository: NewsArticleRepositoryProtocol {
    
    var localArticles: [NewsArticleItem] = []
    
    var remoteArticles: [NewsArticleItem] = []
    
    var shouldFailRemoteFetch = false
    var shouldFailSave = false
    
    
    func fetchLocalArticles() async -> [NewsArticleItem] {
        return localArticles
    }
    
    func fetchRemoteArticles() async throws -> [NewsArticleItem] {
        if shouldFailRemoteFetch {
            throw NSError(
                domain: "UnitTestError",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Remote fetch failed"]
            )
        }
        return remoteArticles
    }
    
    func saveArticles(_ articles: [NewsArticleItem]) throws {
        if shouldFailSave {
            throw NSError(
                domain: "UnitTestError",
                code: 2,
                userInfo: [NSLocalizedDescriptionKey: "Save failed"]
            )
        }
        localArticles.append(contentsOf: articles)
    }
}

//
//  NewsArticleRepositoryProtocol.swift
//  NewsReader
//
//  Created by Vigneswaran on 13/02/25.
//

protocol NewsArticleRepositoryProtocol {
    func fetchLocalArticles() async -> [NewsArticleItem]
    func fetchRemoteArticles() async throws -> [NewsArticleItem]
    func saveArticles(_ articles: [NewsArticleItem]) throws
}

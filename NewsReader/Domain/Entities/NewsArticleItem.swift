//
//  NewsArticleItem.swift
//  NewsReader
//
//  Created by Vigneswaran on 13/02/25.
//

import Foundation

struct NewsArticleItem: Identifiable {
    let id: Int64
    let title: String
    let abstract: String
    let publishedDate: Date
    let updatedDate: Date
    let author: String
    let url: String
    let type: String
    let media: [NewsArticleMediaItem]
    
    var coverImage: NewsArticleMediaItem? {
        if let coverImage = media.first(where: { $0.type == NewsArticleMediaItem.Kind.coverImage }) {
            return coverImage
        }
        return originalImage
    }
    
    var thumbnailImage: NewsArticleMediaItem? {
        if let thumbnailImage = media.first(where: { $0.type == NewsArticleMediaItem.Kind.thumbnail }) {
            return thumbnailImage
        }
        return originalImage
    }
    
    var originalImage: NewsArticleMediaItem? {
        return media.first { $0.type == NewsArticleMediaItem.Kind.original }
    }
    
    var formattedPublishedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: publishedDate)
    }
    
    var formattedUpdatedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM,yyyy hh:mm a zzz"
        return formatter.string(from: updatedDate)
    }
    
    init(id: Int64, title: String, abstract: String, publishedDate: Date, updatedDate: Date, author: String, url: String, type: String, media: [NewsArticleMediaItem]) {
        self.id = id
        self.title = title
        self.abstract = abstract
        self.publishedDate = publishedDate
        self.updatedDate = updatedDate
        self.author = author
        self.url = url
        self.type = type
        self.media = media
    }
}

//
//  NewsArticleModel.swift
//  NewsReader
//
//  Created by Vigneswaran on 13/02/25.
//

import Foundation

class NewsArticleModel: Codable {
    let url: String
    let id: Int64
    let publishedDateString: String
    let updatedDateString: String
    let section: String
    let subsection: String
    let author: String
    let type: String
    let title: String
    let abstract: String
    let media: [NewsArticleMediaModel]

    enum CodingKeys: String, CodingKey {
        case url
        case id
        case publishedDateString = "published_date"
        case updatedDateString = "updated"
        case section
        case subsection
        case author = "byline"
        case type
        case title
        case abstract
        case media
    }
}

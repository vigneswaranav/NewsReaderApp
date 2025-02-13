//
//  NewsArticleMediaModel.swift
//  NewsReader
//
//  Created by Vigneswaran on 13/02/25.
//

import Foundation

class NewsArticleMediaModel: Codable {
    let type: String
    let subtype: String
    let caption: String
    let mediaMetadata: [NewsArticleMediaMetadata]

    enum CodingKeys: String, CodingKey {
        case type
        case subtype
        case caption
        case mediaMetadata = "media-metadata"
    }
}

class NewsArticleMediaMetadata: Codable {
    let url: String
    let format: String
    let height: Int
    let width: Int
}


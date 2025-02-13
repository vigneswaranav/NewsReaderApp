//
//  NewsArticleResponse.swift
//  NewsReader
//
//  Created by Vigneswaran on 13/02/25.
//


import Foundation

struct NewsArticleResponse<U: Decodable>: Decodable {
    
    let status: String
    let totalResults: Int
    let results: [U]
    
    enum CodingKeys: String, CodingKey {
        case status
        case totalResults = "num_results"
        case results
    }
}

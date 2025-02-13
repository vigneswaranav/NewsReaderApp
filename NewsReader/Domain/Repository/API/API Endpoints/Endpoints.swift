//
//  Endpoints.swift
//  NewsReader
//
//  Created by Vigneswaran on 13/02/25.
//

import Foundation

protocol EndpointProtocol {
    var baseUrl: String { get }
    var path: String { get }
    var method: String { get }
    var headers: [String: String] { get }
    var queryItems: [URLQueryItem] { get }
    
    var urlRequest: URLRequest? { get }
}

enum MostPopularSectionType: String {
    case emailed = "emailed"
    case viewed = "viewed"
    case shared = "shared"
}

enum MostPopularPeriodType: Int {
    case day = 1
    case week = 7
    case month = 30
}

enum Endpoints: EndpointProtocol {
    case mostPopular(section: MostPopularSectionType, period: MostPopularPeriodType)
    
    var baseUrl: String {
        return "https://api.nytimes.com/svc/mostpopular/v2"
    }
    
    var path: String {
        switch self {
        case .mostPopular(let section, let period):
            return "/\(section.rawValue)/\(period.rawValue).json"
        }
    }
    
    var method: String {
        return "GET"
    }
    
    var headers: [String : String] {
        return [:]
    }
    
    var queryItems: [URLQueryItem] {
        switch self {
        case .mostPopular:
            return [
                URLQueryItem(name: "api-key", value: APIManager.apiKey)
            ]
        }
    }
    
    var urlRequest: URLRequest? {
        guard var components = URLComponents(string: baseUrl) else {
            return nil
        }
        components.queryItems = queryItems
        components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B").replacingOccurrences(of: "&", with: "%26")
        guard let url = components.url else {
            return nil
        }
        var request = URLRequest(url: url.appendingPathComponent(path))
        request.httpMethod = method
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        headers.forEach { key, value in
            request.addValue(value, forHTTPHeaderField: key)
        }
        return request
    }

}

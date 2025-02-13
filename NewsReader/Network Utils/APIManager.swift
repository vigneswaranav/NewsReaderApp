//
//  APIManager.swift
//  NewsReader
//
//  Created by Vigneswaran on 13/02/25.
//

import Foundation

enum APIError: Error {
    case networkError
    case dataUnavailable
    case responseParsingError
    case invalidRequest
    case requestFailed
}

final class APIManager {
    
    static let shared = APIManager()
    static let apiKey = "Os5FMe950KQY87ly7cZWWNarmAwVPsZO"
        
    private let urlSession: URLSession
    
    private init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }
    
    func execute<T: Decodable>(_ endpoint: EndpointProtocol, codableTo: T.Type) async -> Result<T, APIError> {
        await withCheckedContinuation { continuation in
            guard let request = endpoint.urlRequest else {
                continuation.resume(returning: .failure(.invalidRequest))
                return
            }
            urlSession.dataTask(with: request) { responseData, response, _ in
                guard let response, response.isSuccess else {
                    continuation.resume(returning: .failure(.requestFailed))
                    return
                }
                guard let data = responseData else {
                    continuation.resume(returning: .failure(.dataUnavailable))
                    return
                }
                let responseModel: T
                do {
                    let decoder = JSONDecoder()
                    responseModel = try decoder.decode(codableTo, from: data)
                } catch {
                    continuation.resume(returning: .failure(.responseParsingError))
                    return
                }
                continuation.resume(returning: .success(responseModel))
            }.resume()
        }
    }
}

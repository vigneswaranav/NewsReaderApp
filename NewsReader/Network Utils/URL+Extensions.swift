//
//  URL+Extensions.swift
//  NewsReader
//
//  Created by Vigneswaran on 13/02/25.
//

import Foundation

extension URLResponse {
    
    var isSuccess: Bool {
        guard let response = self as? HTTPURLResponse else { return false }
        return (200...299).contains(response.statusCode)
    }
}

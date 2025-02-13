//
//  DateUtils.swift
//  NewsReader
//
//  Created by Vigneswaran on 13/02/25.
//

import Foundation

class DateUtils {
    
    static func stringToDate(date: String, format: String = "yyyy-MM-dd") -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: date) ?? Date()
    }
    
    static func dateToString(date: Date, format: String = "yyyy-MM-dd") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date)
    }
}

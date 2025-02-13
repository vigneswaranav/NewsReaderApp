//
//  AppDirectories.swift
//  NewsReader
//
//  Created by Vigneswaran on 13/02/25.
//

import Foundation

struct AppDirectories {
    
    static var cachesDirectoryUrl: URL = {
        let urls = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        return urls.last!
    }()
    
    
    static var applicationSupportDirectoryUrl: URL? = {
        let urls = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        return urls.first
    }()
    
    static var documentsDirectoryUrl: URL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls.last!
    }()
}

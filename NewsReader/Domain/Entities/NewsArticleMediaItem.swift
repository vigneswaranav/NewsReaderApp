//
//  NewsArticleMediaItem.swift
//  NewsReader
//
//  Created by Vigneswaran on 13/02/25.
//

struct NewsArticleMediaItem {
    
    enum Kind: Int {
        case thumbnail = 1
        case coverImage = 2
        case original = 3
        
        var identifier: String {
            switch self {
            case .thumbnail:
               return "Standard Thumbnail"
            case .coverImage:
                return "mediumThreeByTwo440"
            case .original:
                return "mediumThreeByTwo210"
            }
        }
        
        static func type(for identifier: String) -> Kind? {
            switch identifier {
            case "Standard Thumbnail":
                return .thumbnail
            case "mediumThreeByTwo440":
                return .coverImage
            case "mediumThreeByTwo210":
                return .original
            default:
                return nil
            }
        }
    }
    
    enum MediaType: String {
        case image = "image"
        case video = "video"
        case audio = "audio"
    }

    let url: String
    let caption: String?
    let mediaType: MediaType
    let type: Kind
    
    init(url: String, caption: String?, type: Kind, mediaType: MediaType) {
        self.url = url
        self.caption = caption
        self.mediaType = mediaType
        self.type = type
    }
    
}

//
//  NewsArticleResponseMapper.swift
//  NewsReader
//
//  Created by Vigneswaran on 13/02/25.
//

class NewsArticleResponseMapper {
   
    static func map(_ response: NewsArticleResponse<NewsArticleModel>) -> [NewsArticleItem] {
        let articles: [NewsArticleItem] = response.results.map({ (result: NewsArticleModel) -> NewsArticleItem in
           
            let media: [NewsArticleMediaModel] = result.media
            let mediaItems: [NewsArticleMediaItem] = media.compactMap({ (media: NewsArticleMediaModel) -> NewsArticleMediaItem? in
                guard let mediaType = NewsArticleMediaItem.MediaType(rawValue: media.type) else {
                    return nil
                }
                for mediaMetadata in media.mediaMetadata {
                    guard let type = NewsArticleMediaItem.Kind.type(for: mediaMetadata.format) else {
                        continue
                    }
                    return NewsArticleMediaItem(url: mediaMetadata.url, caption: media.caption, type: type, mediaType: mediaType)
                }
                return nil
            })
            
            return NewsArticleItem(
                id: result.id,
                title: result.title,
                abstract: result.abstract,
                publishedDate: DateUtils.stringToDate(date: result.publishedDateString),
                updatedDate: DateUtils.stringToDate(date: result.updatedDateString, format: "yyyy-MM-dd HH:mm:ss"),
                author: result.author, url: result.url, type: result.type,
                media: mediaItems)
        })
        
        return articles
    }
}

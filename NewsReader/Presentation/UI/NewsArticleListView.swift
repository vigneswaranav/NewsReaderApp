//
//  NewsArticleListView.swift
//  NewsReader
//
//  Created by Vigneswaran on 13/02/25.
//

import SwiftUI
import Combine

struct NewsArticleListView: View {
    let items: [NewsArticleItem]

    var body: some View {
        NavigationSplitView {
            List(items) { item in
                NavigationLink {
                    NewsArticleDetailView(item: item)
                } label: {
                    NewsArticleListRow(item: item)
                }
                .listRowInsets(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                .listRowSeparator(.hidden)
            }.navigationTitle("Articles")
        } detail: {
            Text("Select an article")
        }
    }
}

#Preview {
    let mediaItem = NewsArticleMediaItem(url: "https://static01.nyt.com/images/2025/02/11/multimedia/11dc-doge-students-photo-btjl/11dc-doge-students-photo-btjl-thumbStandard.jpg",
                                           caption: nil,
                                           type: .thumbnail, mediaType: .image)
    let mediaItem2 = NewsArticleMediaItem(url: "https://static01.nyt.com/images/2025/02/11/multimedia/11dc-doge-students-photo-btjl/11dc-doge-students-photo-btjl-mediumThreeByTwo440.jpg", caption: nil, type: .coverImage, mediaType: .image)
    let item1 = NewsArticleItem(id: 100000009980454, title:"Apparently, America Is Full of the Wrong Kind of People", abstract: "If, according to the president, so many people in the United States are the wrong kind, who makes up the right kind?", publishedDate: DateUtils.stringToDate(date:     "2025-02-11"), updatedDate: DateUtils.stringToDate(date: "2025-02-12 10:02:12", format: "dd-MM-yyyy HH:mm:ss"), author: "By Carlos Lozada", url: "https://www.nytimes.com/2025/02/11/opinion/trump-real-americans-diversity.html", type: "Article", media: [mediaItem, mediaItem2])
    let item2 = NewsArticleItem(id: 10009980452131234, title:"Apparently, America Is Full of the Wrong dfsfsddf of People", abstract: "If, according to the president, so many people in the United States are the wrong kind, who makes up the right kind?", publishedDate: DateUtils.stringToDate(date:     "2025-02-11"), updatedDate: DateUtils.stringToDate(date: "2025-02-12 10:02:12", format: "dd-MM-yyyy HH:mm:ss"), author: "By Carlos Lozada", url: "https://www.nytimes.com/2025/02/11/opinion/trump-real-americans-diversity.html", type: "Article", media: [mediaItem, mediaItem2])
    NewsArticleListView(items: [item1, item2])
}

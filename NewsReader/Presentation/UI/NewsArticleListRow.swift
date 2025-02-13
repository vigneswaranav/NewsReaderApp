//
//  NewsArticleListRow.swift
//  NewsReader
//
//  Created by Vigneswaran on 13/02/25.
//

import SwiftUI

struct NewsArticleListRow: View {
    var item: NewsArticleItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center, spacing: 12) {
                AsyncImage(url: URL(string: item.thumbnailImage?.url ?? "")) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 30))
                } placeholder: {
                    ProgressView()
                }.frame(width: 60, height: 60)
                .cornerRadius(30)
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title)
                        .font(.headline)
                        .lineLimit(2)
                    Text(item.abstract)
                        .font(.subheadline)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    HStack {
                        Text(item.author).font(.callout).lineLimit(2)
                        Spacer()
                        Image(systemName: "calendar")
                        Text(item.publishedDate, style: .date)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.vertical, 4)
            Divider().background(Color(.systemGray4))
        }
    }
}

#Preview {
    let mediaItem = NewsArticleMediaItem(url: "https://static01.nyt.com/images/2025/02/11/multimedia/11dc-doge-students-photo-btjl/11dc-doge-students-photo-btjl-thumbStandard.jpg",
                                           caption: nil,
                                           type: .thumbnail, mediaType: .image)
    let mediaItem2 = NewsArticleMediaItem(url: "https://static01.nyt.com/images/2025/02/11/multimedia/11dc-doge-students-photo-btjl/11dc-doge-students-photo-btjl-mediumThreeByTwo440.jpg", caption: nil, type: .coverImage, mediaType: .image)
    let item1 = NewsArticleItem(id: 100000009980454, title:"Apparently, America Is Full of the Wrong Kind of People", abstract: "If, according to the president, so many people in the United States are the wrong kind, who makes up the right kind?", publishedDate: DateUtils.stringToDate(date:     "2025-02-11"), updatedDate: DateUtils.stringToDate(date: "2025-02-12 10:02:12", format: "dd-MM-yyyy HH:mm:ss"), author: "By Carlos dsfsdf", url: "https://www.nytimes.com/2025/02/11/opinion/trump-real-americans-diversity.html", type: "Article", media: [mediaItem, mediaItem2])
    NewsArticleListRow(item: item1)
}

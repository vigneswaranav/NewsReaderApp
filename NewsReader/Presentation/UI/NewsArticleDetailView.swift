//
//  NewsArticleDetailView.swift
//  NewsReader
//
//  Created by Vigneswaran on 13/02/25.
//


import SwiftUI

struct NewsArticleDetailView: View {
    let item: NewsArticleItem
    
    var body: some View {
        ScrollView {
            if let coverImageUrl = item.coverImage?.url, let url = URL(string: coverImageUrl) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    ProgressView()
                }.frame(width: UIScreen.main.bounds.width, height: 200)
                    .clipped()
                    .padding(.top, 16)
            }
            VStack(alignment: .leading, spacing: 16) {
                Text(item.title)
                    .font(.largeTitle)
                    .bold()
                Text(item.abstract)
                    .font(.body)
                Text(item.author).font(.callout).lineLimit(2).foregroundStyle(.foreground).fontWeight(.semibold)
                HStack {
                    Image(systemName: "calendar").foregroundStyle(.gray)
                    Text(item.publishedDate, style: .date)
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("Updated: \(item.formattedUpdatedDate)").font(.caption)
                        .foregroundColor(.gray).fontWeight(.medium)
                }
                Spacer()
            }
            .padding()
            Button {
                if let url = URL(string: item.url) {
                    UIApplication.shared.open(url)
                }
            } label: {
                Text("Read Full Article")
                    .font(.headline)
                    .foregroundStyle(.white)
            }
            .frame(width: UIScreen.main.bounds.width - 32, height: 50)
                .background(Color.blue)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding()
        }
        .navigationTitle(item.type)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    let mediaItem = NewsArticleMediaItem(url: "https://static01.nyt.com/images/2025/02/11/multimedia/11dc-doge-students-photo-btjl/11dc-doge-students-photo-btjl-thumbStandard.jpg",
                                           caption: nil,
                                           type: .thumbnail, mediaType: .image)
    let mediaItem2 = NewsArticleMediaItem(url: "https://static01.nyt.com/images/2025/02/11/multimedia/11dc-doge-students-photo-btjl/11dc-doge-students-photo-btjl-mediumThreeByTwo440.jpg", caption: nil, type: .coverImage, mediaType: .image)
    let item1 = NewsArticleItem(id: 100000009980454, title:"Apparently, America Is Full of the Wrong Kind of People", abstract: "If, according to the president, so many people in the United States are the wrong kind, who makes up the right kind?", publishedDate: DateUtils.stringToDate(date:     "2025-02-11"), updatedDate: DateUtils.stringToDate(date: "2025-02-12 10:02:12", format: "dd-MM-yyyy HH:mm:ss"), author: "By Carlos dsfsdf", url: "https://www.nytimes.com/2025/02/11/opinion/trump-real-americans-diversity.html", type: "Article", media: [mediaItem, mediaItem2])
    NewsArticleDetailView(item: item1)
}

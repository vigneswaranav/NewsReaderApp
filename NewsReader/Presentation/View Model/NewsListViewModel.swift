//
//  NewsArticleListViewModel.swift
//  NewsReader
//
//  Created by Vigneswaran on 13/02/25.
//

import SwiftUI
import CoreData
import Combine

@MainActor
class NewsArticleListViewModel: ObservableObject {
    private let fetchUseCase: FetchNewsArticleUseCase
    private let frcObserver: FetchResultControllerObserver<NewsArticleSyncHandler>
    private var cancellables = Set<AnyCancellable>()
    
    @Published var articles: [NewsArticleItem] = []
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    
    init(fetchUseCase: FetchNewsArticleUseCase,
         frcObserver: FetchResultControllerObserver<NewsArticleSyncHandler>) {
        self.fetchUseCase = fetchUseCase
        self.frcObserver = frcObserver
        self.frcObserver.fetch()
        
        frcObserver.$objects
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newObjects in
                guard let self = self else { return }
                self.articles = newObjects
            }
            .store(in: &cancellables)
    }
    
    deinit {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }
    
    func loadArticles() async {
        isLoading = true
        let fetchResult = await fetchUseCase.execute()
        isLoading = false
        switch fetchResult {
        case .success(let articles):
            print("Loaded \(articles.count) articles from remote/local")
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }
}

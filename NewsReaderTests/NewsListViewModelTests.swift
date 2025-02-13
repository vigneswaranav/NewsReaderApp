//
//  NewsListViewModelTests.swift
//  NewsReader
//
//  Created by Vigneswaran on 14/02/25.
//


//
//  NewsListViewModelTests.swift
//  NewsReaderTests
//

import XCTest
@testable import NewsReader  // Replace with your actual module name

@MainActor
final class NewsListViewModelTests: XCTestCase {
    
    var fakeRepository: FakeNewsArticleRepository!
    var fetchUseCase: FetchNewsArticleUseCase!
    var viewModel: NewsArticleListViewModel!
    var frcObserver: FetchResultControllerObserver<NewsArticleSyncHandler>!
    
    override func setUp() {
        super.setUp()
        fakeRepository = FakeNewsArticleRepository()
        fetchUseCase = FetchNewsArticleUseCase(repository: fakeRepository)
        frcObserver = FetchResultControllerObserver(entityHandler: NewsArticleSyncHandler.sharedHandler, context: PersistenceController.mainContext)
        viewModel = NewsArticleListViewModel(fetchUseCase: fetchUseCase, frcObserver: frcObserver)
    }
    
    override func tearDown() {
        fakeRepository = nil
        fetchUseCase = nil
        viewModel = nil
        super.tearDown()
    }
    
    func test_loadArticlesSucceeds() async {
        let article = NewsArticleItem(
            id: 102313213123,
            title: "Article 1",
            abstract: "Loerternlkdnv adfklasdfds clasdkmfladsjfsd  lasmvlkasmdflkasdfnasdnkasjndfk;asjnd;fv  ksjnvkasnjdfknasdkfnakjdnfkanjsdfk sdfsadfasdfsad",
            publishedDate: Date(),
            updatedDate: Date(),
            author: "Leonardo da Vinci",
            url: "https://example.com/local.html",
            type: "Article",
            media: []
        )
        
        fakeRepository.remoteArticles = [article]
        
        await viewModel.loadArticles()
        
        XCTAssertNil(viewModel.errorMessage, "Error message should be nil on success")
    }
    
    func test_loadArticlesFails() async {
        fakeRepository.shouldFailRemoteFetch = true
        
        await viewModel.loadArticles()
        
        XCTAssertNotNil(viewModel.errorMessage, "Error message should be set on failure")
    }
    
    func test_loadingStateDuringFetch() async {
        XCTAssertFalse(viewModel.isLoading, "Initially, isLoading should be false")
        
        let loadTask = Task {
            await viewModel.loadArticles()
        }
        
        XCTAssertTrue(viewModel.isLoading, "isLoading should be set as true right after calling load")
        
        await loadTask.value
        
        XCTAssertFalse(viewModel.isLoading, "isLoading should be set as false after load completes")
    }
}

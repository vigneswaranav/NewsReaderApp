//
//  FetchNewsArticleUseCaseTests.swift
//  NewsReader
//
//  Created by Vigneswaran on 14/02/25.
//

import XCTest
@testable import NewsReader  // Replace with the actual module name for your app

@MainActor
final class FetchNewsArticleUseCaseTests: XCTestCase {
    
    private var fakeRepository: FakeNewsArticleRepository!
    private var useCase: FetchNewsArticleUseCase!
    
    override func setUp() {
        super.setUp()
        fakeRepository = FakeNewsArticleRepository()
        useCase = FetchNewsArticleUseCase(repository: fakeRepository)
    }
    
    override func tearDown() {
        fakeRepository = nil
        useCase = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func test_useCaseReturnsLocalArticlesIfPresent() async {
        let localArticle = NewsArticleItem(
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
        fakeRepository.localArticles = [localArticle]
        
        let result = await useCase.execute()
        
        switch result {
        case .success(let articles):
            XCTAssertEqual(articles.count, 1)
            XCTAssertEqual(articles.first?.id, 102313213123)
        case .failure(let error):
            XCTFail("Expected success with local articles, but got error: \(error)")
        }
    }
    
    func test_useCaseRemoteFetchAndSaveIfLocalEmpty() async {
        let remoteArticle = NewsArticleItem(
            id: 22131231,
            title: "Article 2",
            abstract: "Loerternlkdnv adfklasdfds clasdkmfladsjfsd  lasmvlkasmdflkasdfnasdndsfsdfsdfsvsvadsf asdfas kasjndfk;asjnd;fv  ksjnvkasnjdfknasdkfnakjdnfkanjsdfk sdfsadfasdfsad",
            publishedDate: Date(),
            updatedDate: Date(),
            author: "Leonardo da Vinci - 2",
            url: "https://example.com/local-2.html",
            type: "Article",
            media: []
        )
        fakeRepository.remoteArticles = [remoteArticle]
        
        let result = await useCase.execute()
        
        switch result {
        case .success(let articles):
            XCTAssertEqual(articles.count, 1)
            XCTAssertEqual(articles.first?.id, 22131231)
            XCTAssertEqual(fakeRepository.localArticles.count, 1)
            XCTAssertEqual(fakeRepository.localArticles.first?.id, 22131231)
        case .failure(let error):
            XCTFail("Expected success with remote articles, but got error: \(error)")
        }
    }
    
    func test_useCaseThrowErrorIfRemoteFails() async {
        fakeRepository.shouldFailRemoteFetch = true
        
        let result = await useCase.execute()
        
        switch result {
        case .success:
            XCTFail("Expected failure, but got success.")
        case .failure(let error):
            XCTAssertEqual(error.localizedDescription, "Remote fetch failed")
        }
    }
    
    func test_useCaseThrowErrorIfSaveFails() async {
        let remoteArticle = NewsArticleItem(
            id: 3213123123,
            title: "Article 3",
            abstract: "Loerternlkdnv adfklasdfds clasdkmfladsjfsd  lasmvlkasmdflkasdfnasdndsfsdfsdfsvsvadsf asdfas kasjndfk;asjnd;fv  ksjnvkasnjdfknasdkfnakjdnfkanjsdfk sdfsdfsdafsdfsadfasdfsad",
            publishedDate: Date(),
            updatedDate: Date(),
            author: "Leonardo da Vinci - 3",
            url: "https://example.com/local-3.html",
            type: "Article",
            media: []
        )
        fakeRepository.remoteArticles = [remoteArticle]
        fakeRepository.shouldFailSave = true
        
        let result = await useCase.execute()
        
        switch result {
        case .success:
            XCTFail("Expected failure due to save error, but got success.")
        case .failure(let error):
            XCTAssertEqual(error.localizedDescription, "Save failed")
        }
    }
}

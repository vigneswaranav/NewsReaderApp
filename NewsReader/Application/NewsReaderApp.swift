//
//  NewsReaderApp.swift
//  NewsReader
//
//  Created by Vigneswaran on 13/02/25.
//

import SwiftUI

@main
struct NewsReaderApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            let databaseHandler = NewsArticleSyncHandler.sharedHandler
            let repository = NewsArticleRepositoryImpl(databaseHandler: databaseHandler)
            let fetchUseCase = FetchNewsArticleUseCase(repository: repository)
            let frcObserver = FetchResultControllerObserver(entityHandler: databaseHandler, context: PersistenceController.mainContext)
            let viewModel = NewsArticleListViewModel(fetchUseCase: fetchUseCase, frcObserver: frcObserver)
            NewsArticleView(viewModel: viewModel)
                .environment(\.managedObjectContext, PersistenceController.mainContext)
        }
    }
}

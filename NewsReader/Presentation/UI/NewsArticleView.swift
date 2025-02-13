//
//  NewsArticleView.swift
//  NewsReader
//
//  Created by Vigneswaran on 13/02/25.
//


import SwiftUI
import CoreData

struct NewsArticleView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject var viewModel: NewsArticleListViewModel
    
    init(viewModel: NewsArticleListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            NewsArticleListView(items: viewModel.articles)
            if viewModel.isLoading {
                ProgressView("Loading...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemBackground).opacity(0.8))
            }
        }
        .navigationTitle("NY Times Most Popular Articles")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    Task { await viewModel.loadArticles() }
                }) {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
                .accessibilityIdentifier("RefreshButton")
            }
        }
        .alert("Error", isPresented: Binding<Bool>(
            get: { viewModel.errorMessage != nil },
            set: { _ in viewModel.errorMessage = nil }
        )) {
            Button("OK", role: .cancel) { }
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
        
    }
}

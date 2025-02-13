//
//  NewsArticleView.swift
//  NewsReader
//
//  Created by Vigneswaran on 13/02/25.
//


import SwiftUI
import CoreData

struct NewsArticleView: View {
    @StateObject var viewModel: NewsArticleListViewModel
    
    init(viewModel: NewsArticleListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            NavigationSplitView {
                List(viewModel.articles) { item in
                    NavigationLink {
                        NewsArticleDetailView(item: item)
                    } label: {
                        NewsArticleListRow(item: item)
                    }
                    .listRowInsets(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                    .listRowSeparator(.hidden)
                }.navigationTitle("NY Times Articles")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                Task {
                                    await viewModel.loadArticles()
                                }
                            }) {
                                Label("Refresh", systemImage: "arrow.clockwise")
                            }
                            .accessibilityIdentifier("RefreshButton")
                        }
                    }
            } detail: {
                Text("Select an article")
                    .font(.title)
                    .foregroundColor(.secondary)
            }
            .onAppear {
                Task {
                    await viewModel.loadArticles()
                }
            }
            if viewModel.isLoading {
                ProgressView("Loading...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemBackground).opacity(0.8))
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

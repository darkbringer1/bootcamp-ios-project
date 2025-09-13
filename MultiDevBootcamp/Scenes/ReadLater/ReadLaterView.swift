//
//  ReadLaterView.swift
//  MultiDevBootcamp
//
//  Created by dogukaan on 13.09.2025.
//

import SwiftUI

struct ReadLaterView: View {
    @StateObject private var viewModel: ReadLaterViewModel
    
    init(viewModel: ReadLaterViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        List {
            ForEach(viewModel.articles) { article in
                ArticleRowView(
                    article: article,
                    isFavorite: .init(get: {
                        viewModel.isFavorite(article)
                    }, set: { favorited in
                        viewModel.toggleFavorite(for: article)
                    }),
                    isReadLater: .init(
                        get: {
                            viewModel.isReadLater(
                                article.url?.absoluteString ?? ""
                            )
                        },
                        set: { newValue in
                            viewModel.toggleReadLater(
                                for: article
                            )
                        })
                )
            }
        }
        .overlay(alignment: .center) {
            if viewModel.isLoading {
                ProgressView("Loading…")
            } else if let message = viewModel.errorMessage, viewModel.articles.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle")
                    Text(message)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding()
            } else if viewModel.articles.isEmpty {
                ContentUnavailableView("No Articles", systemImage: "newspaper")
            }
        }
        .navigationTitle("Read Later")
        .task {
            await viewModel.refresh()
        }
        .refreshable {
            await viewModel.refresh()
        }
    }
}

#Preview {
    let articlesManager: ArticlesDataManaging? = ReadLaterNewsStorage()
    let vm = ReadLaterViewModel(
        service: BasicNewsService(),
        storage: UserDefaultsNewsStorage(
            defaults: .standard,
            articlesManager: articlesManager
        )
    )
    return NavigationStack {
        ReadLaterView(viewModel: vm)
    }
}

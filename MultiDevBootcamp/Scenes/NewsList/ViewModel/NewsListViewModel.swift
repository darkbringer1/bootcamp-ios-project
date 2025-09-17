//
//  NewsListViewModel.swift
//

import Foundation
import BuddiesNetwork

@MainActor
final class NewsListViewModel: ObservableObject {
    // Input dependencies (swap later):
    private let service: NewsAPIClient
    private let storage: NewsStorageProtocol
    
    // UI state
    @Published private(set) var articles: [NewsArticle] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String? = nil
    
    init(service: NewsAPIClient, storage: NewsStorageProtocol) {
        self.service = service
        self.storage = storage
        // Load cached articles initially
        self.articles = (try? storage.loadArticles()) ?? []
    }
    
    func refresh() async {
        isLoading = true
        defer {
            isLoading = false
        }
        await fetchLatest()
    }
    
    func fetchLatest() async {
        let request = LatestFetchRequest(
            query: nil,
            page: 1,
            pageSize: 10,
            country: "us"
        )
        do {
            for try await response in service.watch(request, cachePolicy: .returnCacheDataAndFetch) {
                articles = response.articles?.enumerated().compactMap { index, item in
                    NewsArticle(
                        id: (item.url ?? UUID().uuidString) + "_\(index)",
                        title: item.title ?? "Untitled",
                        description: item.description,
                        url: item.url.flatMap(URL.init(string:)),
                        imageUrl: item.urlToImage.flatMap(URL.init(string:)),
                        publishedAt: item.publishedAt,
                        sourceName: item.source?.name
                    )
                } ?? []
            }
        } catch {
            print(error)
        }
        
    }
    
    func toggleFavorite(for article: NewsArticle) {
        // First, ensure the article is saved to CoreData
        do {
            // Save the article if it doesn't exist
            if !storage.isArticleSaved(article.url?.absoluteString ?? article.id ?? UUID().uuidString) {
                try storage.saveArticles([article])
            }
            // Toggle favorite status in storage
            try storage.toggleFavorite(
                id: article.url?.absoluteString ?? article.id ?? UUID().uuidString
            )
        } catch {
            errorMessage = error.localizedDescription
            print("Failed to toggle favorite: \(error)")
        }
        objectWillChange.send()
    }
    
    func toggleReadLater(for article: NewsArticle) {
        do {
            // First, save the article if it's not already in storage
            if !storage.isArticleSaved(article.url?.absoluteString ?? article.id ?? UUID().uuidString) {
                try storage.saveArticles([article])
            }
            // Then toggle the read later status
            try storage.toggleReadLater(id: article.url?.absoluteString ?? article.id ?? UUID().uuidString)
        } catch {
            errorMessage = error.localizedDescription
            print("Failed to toggle read later: \(error)")
        }
        objectWillChange.send()
    }
    
    func isFavorite(_ article: NewsArticle) -> Bool {
        // Check if article is favorite
        storage.isFavorite(id: article.url?.absoluteString ?? article.id ?? UUID().uuidString)
    }
    
    func isReadLater(_ article: NewsArticle) -> Bool {
        // Check if article is marked as read later
        storage.isArticleSaved(article.url?.absoluteString ?? article.id ?? UUID().uuidString)
    }
}

extension NewsListViewModel {
    
    struct LatestFetchRequest: Requestable {
        let query: String?
        let page: Int
        let pageSize: Int
        let country: String?
        
        typealias Data = NewsDataResponse

        func httpProperties() -> BuddiesNetwork.HTTPOperation<NewsListViewModel.LatestFetchRequest>.HTTPProperties {
            .init(
                url: EndpointManager.Path.topHeadlines.url(),
                httpMethod: .get,
                data: self
            )
        }
    }
}

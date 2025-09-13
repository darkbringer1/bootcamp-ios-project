//
//  ReadLaterViewModel.swift
//  MultiDevBootcamp
//
//  Created by dogukaan on 13.09.2025.
//

import Foundation

@MainActor
final class ReadLaterViewModel: ObservableObject {
    // Input dependencies (swap later):
    private let service: BasicNewsServiceProtocol
    private let storage: NewsStorage
    
    // UI state
    @Published private(set) var articles: [NewsArticle] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String? = nil
    
    init(
        service: BasicNewsServiceProtocol,
        storage: NewsStorage
    ) {
        self.service = service
        self.storage = storage
        // Load cached articles from coreData
    }
    
    func refresh() async {
        isLoading = true
        defer {
            isLoading = false
        }
        
        // Refresh from core data
        do {
            articles = try storage.loadArticles()
        } catch {
            print("Failed to fetch articles: \(error)")
        }
    }
    
    
    
    func toggleFavorite(for article: NewsArticle) {
        // Toggle favorite status in storage
        do {
            try storage.toggleFavorite(
                id: article.url?.absoluteString ?? ""
            )
            toggleReadLater(for: article)
        } catch {
            print("Failed to toggle favorite: \(error)")
        }
        objectWillChange.send()
    }
    
    func isFavorite(_ article: NewsArticle) -> Bool {
        // Check if article is favorite
        storage.isFavorite(id: article.id)
    }
    
    func isReadLater(_ id: String) -> Bool {
        storage.checkIfSaved(id)
    }
    
    func toggleReadLater(for article: NewsArticle) {
        do {
            if isReadLater(article.id) {
//                try storage.
            } else {
                try storage.saveArticles([article])
            }
        } catch {
            print("Failed to toggle read later: \(error)")
        }
        objectWillChange.send()
    }
}

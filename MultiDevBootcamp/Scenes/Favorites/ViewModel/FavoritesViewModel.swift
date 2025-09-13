//
//  FavoritesViewModel.swift
//

import Foundation

@MainActor
final class FavoritesViewModel: ObservableObject {
    private let storage: NewsStorage
    
    @Published private(set) var favoriteArticles: [NewsArticle] = []
    
    init(storage: NewsStorage) {
        self.storage = storage
        // Preload from storage only
    }
    
    func reload() {
        // Load all articles and filter to favorites
        do {
            let all = try storage.loadArticles()
            favoriteArticles = all.filter { isFavorite($0) }
        } catch {
            print("Failed to load articles: \(error)")
        }
    }
    
    func toggleFavorite(for article: NewsArticle) {
        // Toggle favorite status and reload favorites
        do {
            try storage.toggleFavorite(id: article.id)
        } catch {
            print("Failed to toggle favorite: \(error)")
        }
        reload()
        objectWillChange.send()
    }
    
    func isFavorite(_ article: NewsArticle) -> Bool {
        // Check if article is favorite
        storage.isFavorite(id: article.id)
    }
}

//
//  ReadLaterNewsStorage.swift
//  MultiDevBootcamp
//
//  Created by dogukaan on 13.09.2025.
//

import Foundation

final class ReadLaterNewsStorage: ArticlesDataManaging {
    let readLaterCoreDataManager: ReadLaterCoreDataManagerProtocol
    
    init(readLaterCoreDataManager: ReadLaterCoreDataManagerProtocol? = nil) {
        self.readLaterCoreDataManager = readLaterCoreDataManager ?? ReadLaterCoreDataManager()
    }
    
    func saveArticles(_ articles: [NewsArticle]) throws {
        readLaterCoreDataManager.save(articles)
    }

    func loadArticles() throws -> [NewsArticle] {
        readLaterCoreDataManager.fetchAll()
    }
    
    func checkIfSaved(_ id: String) -> Bool {
        readLaterCoreDataManager.checkIfSaved(id)
    }
}

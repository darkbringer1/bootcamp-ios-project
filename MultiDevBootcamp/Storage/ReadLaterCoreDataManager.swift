//
//  ReadLaterCoreDataManager.swift
//  MultiDevBootcamp
//
//  Created by dogukaan on 13.09.2025.
//

import Foundation

protocol ReadLaterCoreDataManagerProtocol {
    var coreDataManager: CoreDataManager { get }
    func save(_ items: [NewsArticle])
    func fetchAll() -> [NewsArticle]
    func delete(_ item: NewsArticle)
    func deleteAll()
}

final class ReadLaterCoreDataManager: ReadLaterCoreDataManagerProtocol {

    var coreDataManager: CoreDataManager

    init() {
        coreDataManager = CoreDataManager.shared
    }
    
    func save(_ items: [NewsArticle]) {
        let articles = fetchAll()
        
        for item in items {
            if articles.contains(where: { $0.url == item.url }) {
                continue
            }
            let object = ArticleEntity(context: coreDataManager.context)
            object.title = item.title
            object.articleDescription = item.description
            object.articleUrl = item.url?.absoluteString
            object.articleImageUrl = item.imageUrl?.absoluteString
            object.publishedAt = item.publishedAt
            object.sourceName = item.sourceName
            object.isFavorite = item.isFavorite
            
            coreDataManager.saveContext()
            
        }
    }

    func fetchAll() -> [NewsArticle] {
        let entities = coreDataManager.fetch(ArticleEntity.self)
        
        return entities.map { entity in
            NewsArticle(
                id: entity.objectID.description,
                title: entity.title ?? "",
                description: entity.articleDescription,
                url: URL(string: entity.articleUrl ?? ""),
                imageUrl: URL(string: entity.articleImageUrl ?? ""),
                publishedAt: entity.publishedAt,
                sourceName: entity.sourceName,
                isFavorite: entity.isFavorite
            )
        }
    }

    func delete(_ item: NewsArticle) {
        let articles = coreDataManager.fetch(ArticleEntity.self)
        
        if let articleToDelete = articles.first(where: { $0.articleUrl == item.url?.absoluteString }) {
            coreDataManager.context.delete(articleToDelete)
            coreDataManager.saveContext()
        }
    }

    func deleteAll() {
        let articles = coreDataManager.fetch(ArticleEntity.self)
        
        for article in articles {
            coreDataManager.context.delete(article)
        }
        coreDataManager.saveContext()
    }
}

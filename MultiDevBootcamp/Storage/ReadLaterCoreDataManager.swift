//
//  ReadLaterCoreDataManager.swift
//  MultiDevBootcamp
//
//  Created by dogukaan on 13.09.2025.
//

import Foundation

protocol ReadLaterCoreDataManagerProtocol {
    var coreDataManager: CoreDataManager { get }
    func save(_ items: [Article])
    func fetchAll() -> [Article]
    func delete(_ item: Article)
    func deleteAll()
}

final class ReadLaterCoreDataManager: ReadLaterCoreDataManagerProtocol {

    var coreDataManager: CoreDataManager

    init() {
        coreDataManager = CoreDataManager.shared
    }
    
    func save(_ items: [Article]) {
        
    }

    func fetchAll() -> [Article] {
        coreDataManager.fetch(<#T##type: NSManagedObject.Type##NSManagedObject.Type#>)
    }

    func delete(_ item: Article) {
        
    }

    func deleteAll() {
        
    }
}

//
//  CoreDataManager.swift
//  Skeleton aligned with NewsAPICase style
//
//  Notes:
//  - Uses an in-memory store by default so the app runs without a .xcdatamodeld file.
//  - Later in the lesson, point the container to a real model (ArticleEntity) and disk store.
//  - API mirrors NewsAPICase: saveContext, fetch, fetchWithPredicate, delete.
//

import Foundation
import CoreData

final class CoreDataManager: ObservableObject {
    static let shared = CoreDataManager()
    
    // Expose main context (later you can add background contexts as needed)
    let context: NSManagedObjectContext
    
    private init() {
        let container = CoreDataManager.makePersistentContainer()
        self.context = container.newBackgroundContext()
        self.context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        self.persistentContainer = container
    }
    
    // Keep a reference if you need to load stores again or create new contexts
    private let persistentContainer: NSPersistentContainer
    
    // MARK: - Persistent Container (In-Memory for Skeleton)
    private static func makePersistentContainer() -> NSPersistentContainer {
        // Try to merge any model in the bundle. If none exist, fall back to an empty model.
        let model = NSManagedObjectModel.mergedModel(from: [Bundle.main]) ?? NSManagedObjectModel()
        
        // Name kept as "ArticleEntity" to mirror NewsAPICase; you can rename later.
        let container = NSPersistentContainer(name: "ArticleContainer", managedObjectModel: model)
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { _, error in
            if let error {
                debugPrint("CoreData in-memory store failed to load: \(error)")
            }
        }
        return container
    }
    
    // MARK: - Saving
    func saveContext() {
        guard context.hasChanges else { return }
        do { try context.save() } catch { debugPrint("CoreData save error: \(error)") }
    }
    
    // MARK: - Fetching
    func fetch<T: NSManagedObject>(_ type: T.Type) -> [T] {
        do {
            if let fetched = try context.fetch(T.fetchRequest()) as? [T] { return fetched }
        } catch { debugPrint("Fetch error for \(type): \(error)") }
        return []
    }
    
    func fetchWithPredicate<T: NSManagedObject>(_ type: T.Type, predicateKey: String, predicateValue: String) -> T? {
        do {
            let request = T.fetchRequest()
            request.predicate = NSPredicate(format: "\(predicateKey) == %@", predicateValue)
            if let fetched = try context.fetch(request) as? [T] { return fetched.first }
        } catch { debugPrint("Fetch (predicate) error for \(type): \(error)") }
        return nil
    }
    
    // MARK: - Deletion
    func delete(_ object: NSManagedObject) {
        context.delete(object)
        saveContext()
    }
}



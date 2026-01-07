//
//  CoreDataService.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 04.02.2025.
//

import Foundation
@preconcurrency import CoreData

protocol ICoreDataService: Sendable {
   
    func fetch<T: NSManagedObject>(fetchRequest: NSFetchRequest<T>) async throws -> [T]
        
    func save(_ block: @escaping (NSManagedObjectContext) throws -> Void) async throws
    
    func delete(with id: String) async throws
    
    #if DEBUG
    func reset()
    #endif
}

final class CoreDataService: @unchecked Sendable {
    
    private let persistentContainer: NSPersistentContainer = {
        let persistentContainer = NSPersistentContainer(name: "Location")
        persistentContainer.loadPersistentStores { _, error in
            guard let error = error else { return }
            print(error.localizedDescription)
        }
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
        persistentContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return persistentContainer
    }()
    
    private var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
}

extension CoreDataService: ICoreDataService {
    
    func fetch<T>(fetchRequest: NSFetchRequest<T>) async throws -> [T] where T : NSManagedObject {
        try await viewContext.perform {
            try self.viewContext.fetch(fetchRequest)
        }
    }
    
    func save(_ block: @escaping (NSManagedObjectContext) throws -> Void) async throws {
        let backgroundContext = persistentContainer.newBackgroundContext()
        try await backgroundContext.perform {
            try block(backgroundContext)
            if backgroundContext.hasChanges {
                try backgroundContext.save()
            }
        }
    }
    
    func delete(with id: String) async throws {
        let backgroundContext = persistentContainer.newBackgroundContext()
        try await backgroundContext.perform {
            let fetchRequest = LocationDB.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", id)
            let locations = try backgroundContext.fetch(fetchRequest)
            locations.forEach { backgroundContext.delete($0) }
            try backgroundContext.save()
        }
    }
    
    #if DEBUG
    func reset() {
        let backgroundContext = persistentContainer.newBackgroundContext()
        backgroundContext.perform {
            let fetchRequest = LocationDB.fetchRequest()
            do {
                let locations = try backgroundContext.fetch(fetchRequest)
                locations.forEach { backgroundContext.delete($0) }
                try backgroundContext.save()
            } catch {
                print("Error while resetting coreData storage")
            }
        }
    }
    #endif
}

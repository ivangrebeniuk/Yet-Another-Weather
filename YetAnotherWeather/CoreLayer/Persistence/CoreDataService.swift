//
//  CoreDataService.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 04.02.2025.
//

import Foundation
import CoreData

protocol ICoreDataService: AnyObject {
    
    func fetch<T: NSManagedObject>(fetchRequest: NSFetchRequest<T>) throws -> [T]
    
    func save(
        _ block: @escaping (NSManagedObjectContext) throws -> Void,
        completion: @escaping (() -> Void)
    )

    func delete(with id: String, completion: @escaping () -> Void)
}

final class CoreDataService {
    
    private let persistentContainer: NSPersistentContainer = {
        let persistentContainer = NSPersistentContainer(name: "Location")
        persistentContainer.loadPersistentStores { _, error in
            guard let error = error else { return }
            print(error.localizedDescription)
        }
        return persistentContainer
    }()
    
    private var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
}

extension CoreDataService: ICoreDataService {
    
    func fetch<T>(fetchRequest: NSFetchRequest<T>) throws -> [T] where T : NSManagedObject {
        try viewContext.fetch(fetchRequest)
    }
    
    func save(
        _ block: @escaping (NSManagedObjectContext) throws -> Void,
        completion: @escaping (() -> Void)
    ) {
        let backgroundContext = persistentContainer.newBackgroundContext()
        backgroundContext.perform {
            do {
                try block(backgroundContext)
                if backgroundContext.hasChanges {
                    try backgroundContext.save()
                }
            } catch {
                print("!!! Error while saving location to coreData")
            }
            completion()
        }
    }
    
    func delete(with id: String, completion: @escaping () -> Void) {
        let backgroundContext = persistentContainer.newBackgroundContext()
        backgroundContext.perform {
            let fetchRequest = LocationDB.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", id)
            do {
                let locations = try backgroundContext.fetch(fetchRequest)
                locations.forEach { backgroundContext.delete($0) }
                try backgroundContext.save()
            } catch {
                print("!!! Error while deleting location from coreData")
            }
            completion()
        }
    }
}

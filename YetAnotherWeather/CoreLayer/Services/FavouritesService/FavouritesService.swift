//
//  FavouritesService.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 09.02.2025.
//

import Foundation

protocol IFavouritesService: AnyObject {
    
    var cachedFavourites: [Location] { get }
            
    func saveToFavourites(_ location: Location, completion: @escaping () -> Void)
    
    func deleteFromFavourites(_ index: Int)
}

final class FavouritesService {
    
    // Dependencies
    private let accessQueue: DispatchQueue
    private let coreDataService: ICoreDataService
    private let dataBaseQueue: DispatchQueue
    
    // Models
    private lazy var locations: [Location] = fetchLocations()

    
    // MARK: - Init
    
    init(
        accessQueue: DispatchQueue,
        coreDataService: ICoreDataService,
        dataBaseQueue: DispatchQueue
    ) {
        self.accessQueue = accessQueue
        self.coreDataService = coreDataService
        self.dataBaseQueue = dataBaseQueue
    }
    
    // MARK: - Private
    
    private func fetchLocations() -> [Location] {
        do {
            let fetchRequest = LocationDB.fetchRequest()
            let sortDescriptor = NSSortDescriptor(key: "timeStamp", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptor]
            
            let locationDBs = try coreDataService.fetch(fetchRequest: fetchRequest)
            
            return locationDBs.compactMap { locationDB in
                guard
                    let id = locationDB.id,
                    let name = locationDB.name
                else {
                    return nil
                }
                
                return Location(id: id, name: name, timeStamp: locationDB.timeStamp)
            }
            
        } catch {
            return []
        }
    }
}

// MARK: - IFavouritesService

extension FavouritesService: IFavouritesService {
    
    var cachedFavourites: [Location] {
        accessQueue.sync {
            return locations
        }
    }
    
    func saveToFavourites(_ location: Location, completion: @escaping () -> Void) {
        dataBaseQueue.async { [weak self] in
            self?.coreDataService.save ({ context in
                let fetchRequest = LocationDB.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "id = %@", location.id as CVarArg)
                
                let locationDBs = try context.fetch(fetchRequest)
                
                // Проверяем, что объект с таким id не существует в контексте
                if locationDBs.isEmpty {
                    // Объект с таким id не существует, создаем новый
                    let newLocationDB = LocationDB(context: context)
                    newLocationDB.id = location.id
                    newLocationDB.name = location.name
                    newLocationDB.timeStamp = location.timeStamp
                } else {
                    return
                }
            }, completion: {
                self?.accessQueue.sync {
                    self?.locations.append(location)
                }
                completion()
            }
        )}
    }
    
    func deleteFromFavourites(_ index: Int) {
        let cached = cachedFavourites
        dataBaseQueue.async { [weak self] in
            guard let self else { return }
            guard index < cached.count else { return }
            let locationId = cached[index].id
            coreDataService.delete(with: locationId) { [weak self] in
                self?.accessQueue.sync { [weak self] in
                    self?.locations.removeAll {
                        $0.id == locationId
                    }
                }
            }
        }
    }
}

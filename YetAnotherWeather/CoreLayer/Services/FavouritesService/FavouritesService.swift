//
//  FavouritesService.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 09.02.2025.
//

import Foundation

protocol IFavouritesService: AnyObject {
    func cachedFavourites() async -> [Location]
    func isFavourite(_ locationId: String) async -> Bool
    func saveToFavourites(_ location: Location) async throws
    func deleteFromFavourites(_ index: Int) async throws
}

actor FavouritesService {
    private let coreDataService: ICoreDataService
    private var locations: [Location] = []
    
    init(coreDataService: ICoreDataService) {
        self.coreDataService = coreDataService
    }
    
    private func fetchLocations() async -> [Location] {
        do {
            let fetchRequest = LocationDB.fetchRequest()
            let sortDescriptor = NSSortDescriptor(key: "timeStamp", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptor]
            
            let locationDBs = try await coreDataService.fetch(fetchRequest: fetchRequest)
            
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
            print("❌ Ошибка при загрузке локаций из CoreData: \(error)")
            return []
        }
    }
    
    private func removeLocation(_ locationId: String) {
        locations.removeAll { $0.id == locationId }
    }
}

extension FavouritesService: IFavouritesService {
    
    func cachedFavourites() async -> [Location] {
        if locations.isEmpty {
            locations = await fetchLocations()
        }
        return locations
    }
    
    func isFavourite(_ locationId: String) async -> Bool {
        if locations.isEmpty {
            locations = await fetchLocations()
        }
        
        return locations.contains { $0.id == locationId }
    }
    
    func saveToFavourites(_ location: Location) async throws {
        guard !locations.contains(where: { $0.id == location.id }) else {
            return
        }
        
        try await coreDataService.save { context in
            let fetchRequest = LocationDB.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id = %@", location.id as CVarArg)
            
            let locationDBs = try context.fetch(fetchRequest)
            
            if locationDBs.isEmpty {
                let newLocationDB = LocationDB(context: context)
                newLocationDB.id = location.id
                newLocationDB.name = location.name
                newLocationDB.timeStamp = location.timeStamp
            }
        }
        locations.append(location)
    }
    
    func deleteFromFavourites(_ index: Int) async throws {
        guard index < locations.count else { return }
        let locationId = locations[index].id
        try await coreDataService.delete(with: locationId)
        removeLocation(locationId)
    }
}

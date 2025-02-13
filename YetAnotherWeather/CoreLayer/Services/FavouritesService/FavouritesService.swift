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
    private let coreDataService: ICoreDataService
    private let dataBaseQueue: DispatchQueue
    private let userDefaults: UserDefaults

    
    // MARK: - Init
    
    init(
        coreDataService: ICoreDataService,
        dataBaseQueue: DispatchQueue,
        userDefaults: UserDefaults
    ) {
        self.coreDataService = coreDataService
        self.dataBaseQueue = dataBaseQueue
        self.userDefaults = userDefaults
    }
}

// MARK: - IFavouritesService

extension FavouritesService: IFavouritesService {
    
    //    2/ через делегат лист обновлять кэш в нужных презентерах из CurrentWeatherService
    
    var cachedFavourites: [Location] {
        do {
            let fetchRequest = LocationDB.fetchRequest()
            let sortDescriptor = NSSortDescriptor(key: "timeStamp", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptor]
            
            let locationDBs = try coreDataService.fetch(fetchRequest: fetchRequest)
            
            let locations: [Location] = locationDBs.compactMap { locationDB in
                guard
                    let id = locationDB.id,
                    let name = locationDB.name
                else {
                    return nil
                }
                
                return Location(id: id, name: name, timeStamp: locationDB.timeStamp)
            }
            
            return locations
            
        } catch {
            print(error)
            return []
        }
    }
    
    func saveToFavourites(_ location: Location, completion: @escaping () -> Void) {
        dataBaseQueue.async { [weak self] in
            self?.coreDataService.save ({ context in
                let fetchRequest = LocationDB.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "id = %@", location.id as CVarArg)
                
                let locationDBs = try context.fetch(fetchRequest)
                
                // Проверяем, если объект с таким id уже существует
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
                completion()
            }
        )}
    }
    
    func deleteFromFavourites(_ index: Int) {
        dataBaseQueue.async { [weak self] in
            guard let self else { return }
            let cached = cachedFavourites
            guard index < cached.count else { return }
            let locationId = cached[index].id
            coreDataService.delete(with: locationId)
        }
    }
}

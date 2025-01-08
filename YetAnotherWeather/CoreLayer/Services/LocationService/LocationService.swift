//
//  LocationService.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 04.01.2025.
//

import Foundation
import CoreLocation

enum LocationError: Error {
    case deniedError
    case restrictedError
    case locationNotAvailable
}

protocol ILocationService: AnyObject {
    func checkAuthorizationStatus()
    func getLocation(completion: @escaping (Result<CLLocation, Error>) -> Void)
}

final class LocationService: NSObject {
    
    // Dependencies
    private let locationManager = CLLocationManager()
    
    // Models
    private var currentLocationCompletion: ((Result<CLLocation, Error>) -> Void)?
    
    // MARK: - Init
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }
    
    // MARK: - Private Methods
    
    private func requestLocationAccess() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    private func requestLocation() {
        locationManager.requestLocation()
    }
}

// MARK: - ILocationService

extension LocationService: ILocationService {
    
    func getLocation(completion: @escaping (Result<CLLocation, Error>) -> Void) {
        currentLocationCompletion = completion
        checkAuthorizationStatus()
    }
    
    func checkAuthorizationStatus() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            requestLocationAccess()
        case .authorizedAlways, .authorizedWhenInUse:
            requestLocation()
        case .denied:
            handleLocationError(.deniedError)
        case .restricted:
            handleLocationError(.restrictedError)
        @unknown default:
            handleLocationError(.locationNotAvailable)
        }
    }
    
    private func handleLocationError(_ error: LocationError) {
        // Проверяем, что у нас есть completion для локации
        if let completion = currentLocationCompletion {
            completion(.failure(error))
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationService: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkAuthorizationStatus() // Обновляем статус авторизации при его изменении
    }
    
    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let location = locations.first else {
            handleLocationError(.locationNotAvailable)
            return
        }
        
        // Возвращаем успешно полученную локацию
        if let completion = currentLocationCompletion {
            completion(.success(location))
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Ошибка получения локации: \(error.localizedDescription)")
        
        // Если локация не получена, передаем ошибку
        if let completion = currentLocationCompletion {
            completion(.failure(error))
        }
    }
}

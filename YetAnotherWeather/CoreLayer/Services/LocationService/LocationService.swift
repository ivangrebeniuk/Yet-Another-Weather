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
    func getLocation(completion: @escaping (Result<String, Error>) -> Void)
}

final class LocationService: NSObject {
    
    // Dependencies
    private let locationManager = CLLocationManager()
    
    // Models
    private var currentLocationCompletion: ((Result<String, Error>) -> Void)?
    
    // MARK: - Init
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }
    
    // MARK: - Private
    
    private func requestLocationAccess() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    private func requestLocation() {
        locationManager.requestLocation()
    }
    
    private func checkAuthorizationStatus() {
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
        currentLocationCompletion?(.failure(error))
        currentLocationCompletion = nil
    }
}

// MARK: - ILocationService

extension LocationService: ILocationService {
    
    func getLocation(completion: @escaping (Result<String, Error>) -> Void) {
        currentLocationCompletion = completion
        checkAuthorizationStatus()
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationService: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkAuthorizationStatus()
    }
    
    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let location = locations.first else {
            handleLocationError(.locationNotAvailable)
            return
        }
        let locationString = "\(location.coordinate.latitude),\(location.coordinate.longitude)"
        
        if let completion = currentLocationCompletion {
            completion(.success(locationString))
            currentLocationCompletion = nil
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Ошибка получения локации: \(error.localizedDescription)")
        
        if let completion = currentLocationCompletion {
            completion(.failure(error))
        }
    }
}

//
//  CurrentWeatherListFlowCoordinator.swift
//  YetAnotherWeather
//
//  Created by Иван Гребенюк on 19.05.2024.
//

import Foundation
import UIKit

final class CurrentWeatherListFlowCoordinator {
    
    // Dependecies
    private let currentWeatherListAssembly: CurrentWeatherListAssembly
    private let weatherDetailsAssembly: WeatherDetailsAssembly
    private let weatherDetailsFlowCoordinator: WeatherDetailsFlowCoordinator
    
    private weak var currentWeatherListInput: CurrentWeatherListInput?
    private weak var navigationController: UINavigationController?
    
    // MARK: - Init
    
    init(
        currentWeatherListAssembly: CurrentWeatherListAssembly,
        weatherDetailsAssembly: WeatherDetailsAssembly,
        weatherDetailsFlowCoordinator: WeatherDetailsFlowCoordinator
    ) {
        self.currentWeatherListAssembly = currentWeatherListAssembly
        self.weatherDetailsAssembly = weatherDetailsAssembly
        self.weatherDetailsFlowCoordinator = weatherDetailsFlowCoordinator
    }
    
    func start(with navigationController: UINavigationController) {
        let currentWeatherModule = currentWeatherListAssembly.assemble(output: self)
        
        self.currentWeatherListInput = currentWeatherModule.moduleInput
        self.navigationController = navigationController
        
        navigationController.pushViewController(currentWeatherModule.viewController, animated: true)
    }
    
    // MARK: - Private
    
    private func openWeatherDetails(for location: Location, isCurrentLocation: Bool) {
        weatherDetailsFlowCoordinator.start(
            from: navigationController,
            location: location,
            isCurrentLocation: isCurrentLocation,
            output: self
        )
    }
}

// MARK: - CurrentWeatherListOutput

extension CurrentWeatherListFlowCoordinator: CurrentWeatherListOutput {
    func didSelectLocation(_ location: Location, isCurrentLocation: Bool) {
        openWeatherDetails(for: location, isCurrentLocation: isCurrentLocation)
    }
}

// MARK: WeatherDetailsModuleOutput

extension CurrentWeatherListFlowCoordinator: WeatherDetailsModuleOutput {
    
    func didAddLocationToFavourites(location: Location?) {
        if let location {
            currentWeatherListInput?.addToFavourites(location: location)
        }
    }
}

//
//  CurrentWeatherListCoordinator.swift
//  YetAnotherWeather
//
//  Created by Иван Гребенюк on 19.05.2024.
//

import Foundation
import UIKit


final class CurrentWeatherListCoordinator {
    
    private let currentWeatherListAssembly: CurrentWeatherListAssembly
    private let weatherDetailsAssembly: WeatherDetailsAssembly
    private weak var navigationController: UIViewController?
        
    init(
        currentWeatherListAssembly: CurrentWeatherListAssembly,
        weatherDetailsAssembly: WeatherDetailsAssembly
    ) {
        self.currentWeatherListAssembly = currentWeatherListAssembly
        self.weatherDetailsAssembly = weatherDetailsAssembly
    }
    
    func start(with navigationController: UINavigationController) {
        let viewController = currentWeatherListAssembly.assemble(output: self)
        
        self.navigationController = navigationController
        navigationController.pushViewController(viewController, animated: true)
    }
    
    // MARK: - Private
    
    private func openWeatherDetails(for location: String) {
        let weatherDetailsViewController = weatherDetailsAssembly.assemble(location: location)
        navigationController?.present(weatherDetailsViewController, animated: true)
    }
}

// MARK: - CurrentWeatherListOutput

extension CurrentWeatherListCoordinator: CurrentWeatherListOutput {
    
    func didSelectFuckingLocation(_ location: String) {
        print("Did select fucking location output")
        openWeatherDetails(for: location)
    }
}

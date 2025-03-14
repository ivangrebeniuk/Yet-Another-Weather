//
//  WeatherDetailsFlowCoordinator.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 26.09.2024.
//

import Foundation
import UIKit

protocol WeatherDetailsModuleOutput: AnyObject {
    func didAddLocationToFavourites(location: Location?)
}

final class WeatherDetailsFlowCoordinator {
    
    // Dependencies
    private let weatherDetailsAssembly: WeatherDetailsAssembly
    private weak var transitionHandler: UIViewController?
    private weak var moduleOutput: WeatherDetailsModuleOutput?

    
    // MARK: - Init
    
    init(
        weatherDetailsAssembly: WeatherDetailsAssembly
    ) {
        self.weatherDetailsAssembly = weatherDetailsAssembly
    }
    
    func start(
        from transitionHandler: UIViewController?,
        locationId: String,
        isCurrentLocation: Bool,
        moduleOutput: WeatherDetailsModuleOutput
    ) {
        self.transitionHandler = transitionHandler
        self.moduleOutput = moduleOutput
        
        let viewController = weatherDetailsAssembly.assemble(
            locationId: locationId,
            isCurrentLocation: isCurrentLocation,
            output: self
        )
        
        transitionHandler?.present(UINavigationController(rootViewController: viewController), animated: true)
    }
}

// MARK: - WeatherDetailsOutput

extension WeatherDetailsFlowCoordinator: WeatherDetailsOutput {
    
    func didRequestToDismiss() {
        transitionHandler?.dismiss(animated: true)
    }
    
    func didAddLocationToFavourites(location: Location?) {
        transitionHandler?.dismiss(animated: true)
        moduleOutput?.didAddLocationToFavourites(location: location)
    }
}

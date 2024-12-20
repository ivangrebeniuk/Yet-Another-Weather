//
//  WeatherDetailsFlowCoordinator.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 26.09.2024.
//

import Foundation
import UIKit

protocol WeatherDetailsModuleOutput: AnyObject {
    func didAddLocationToFavourites(location: String?)
}

final class WeatherDetailsFlowCoordinator {
    
    // Dependencies
    private let weatherDetailsAssembly: WeatherDetailsAssembly
    private weak var transitionHandler: UIViewController?
    private weak var output: WeatherDetailsModuleOutput?

    
    // MARK: - Init
    
    init(
        weatherDetailsAssembly: WeatherDetailsAssembly
    ) {
        self.weatherDetailsAssembly = weatherDetailsAssembly
    }
    
    func start(
        from transitionHandler: UIViewController?,
        location: String,
        isAddedToFavourites: Bool,
        output: WeatherDetailsModuleOutput
    ) {
        self.transitionHandler = transitionHandler
        self.output = output
        
        let viewController = weatherDetailsAssembly.assemble(
            location: location,
            isAddedToFavourites: isAddedToFavourites,
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
    
    func didAddLocationToFavourites(location: String?) {
        transitionHandler?.dismiss(animated: true)
        output?.didAddLocationToFavourites(location: location)
    }
}

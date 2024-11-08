//
//  WeatherDetailsAssembly.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 30.07.2024.
//

import Foundation
import UIKit

final class WeatherDetailsAssembly {
    
    // Dependenciec
    private let forecastService: IForecastService
    private let backgroundImageResolver: IBackgroundImageResolver
    
    // MARK: - Init
    
    init(
        weatherForecastService: IForecastService,
        backgroundImageResolver: IBackgroundImageResolver
    ) {
        self.forecastService = weatherForecastService
        self.backgroundImageResolver = backgroundImageResolver
    }
    
    func assemble(location: String, output: WeatherDetailsOutput) -> UIViewController {
        
        let viewModelFactory = WeatherDetailsViewModelFactory(
            backgroundImageResolver: backgroundImageResolver
        )
        
        let presenter = WeatherDetailsPresenter(
            forecastService: forecastService,
            viewModelFactory: viewModelFactory,
            location: location,
            output: output
        )
        
        let vc = WeatherDetailsViewController(presenter: presenter)
        presenter.view = vc
        
        return vc
    }
}

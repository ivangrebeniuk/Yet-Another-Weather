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
    let weatherForecastService: IWeatherForecastService
    
    // MARK: - Init
    
    init(weatherForecastService: IWeatherForecastService) {
        self.weatherForecastService = weatherForecastService
    }
    
    func assemble(location: String) -> UIViewController {
        
        let viewModelFactory = WeatherDetailsViewModelFactory()
        
        let presenter = WeatherDetailsPresenter(
            weatherForecastService: weatherForecastService,
            viewModelFactory: viewModelFactory,
            location: location
        )
        
        let vc = WeatherDetailsViewController(presenter: presenter)
        presenter.view = vc
        
        return vc
    }
}

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
    let forecastService: IForecastService
    
    // MARK: - Init
    
    init(weatherForecastService: IForecastService) {
        self.forecastService = weatherForecastService
    }
    
    func assemble(location: String, output: WeatherDetailsOutput) -> UIViewController {
        
        let viewModelFactory = WeatherDetailsViewModelFactory()
        
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

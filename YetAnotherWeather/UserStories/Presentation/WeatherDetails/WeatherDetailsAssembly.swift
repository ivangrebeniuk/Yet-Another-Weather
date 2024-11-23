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
    private let dateFormatter: ICustomDateFormatter
    private let forecastService: IForecastService
    
    // MARK: - Init
    
    init(
        dateFormatter: ICustomDateFormatter,
        forecastService: IForecastService
    ) {
        self.dateFormatter = dateFormatter
        self.forecastService = forecastService
    }
    
    func assemble(location: String, output: WeatherDetailsOutput) -> UIViewController {
        
        let viewModelFactory = WeatherDetailsViewModelFactory(dateFormatter: dateFormatter)
        let alertViewModelFactory = AlertViewModelFactory()
        
        let presenter = WeatherDetailsPresenter(
            alertViewModelFactory: alertViewModelFactory,
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

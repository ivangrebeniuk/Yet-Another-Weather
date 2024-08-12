//
//  WeatherDetailsPresenter.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 30.07.2024.
//

import Foundation

protocol IWeatherDetailsPresenter {
    func viewDidLoad()
}

final class WeatherDetailsPresenter {
    
    // Dependencies
    
    private let weatherForecastService: IWeatherForecastService
    private let viewModelFactory: IWeatherDetailsViewModelFactory
    private let location: String
    
    weak var view: IWeatherDetailsView?
    
    // MARK: - Init
    
    init(
        weatherForecastService: IWeatherForecastService,
        viewModelFactory: IWeatherDetailsViewModelFactory,
        location: String
    ) {
        self.weatherForecastService = weatherForecastService
        self.viewModelFactory = viewModelFactory
        self.location = location
    }
    
}

// MARK: - IWeatherDetailsPresenter

extension WeatherDetailsPresenter: IWeatherDetailsPresenter {
    
    func viewDidLoad() {
        print("Открыли Детали погоды")
    }
}

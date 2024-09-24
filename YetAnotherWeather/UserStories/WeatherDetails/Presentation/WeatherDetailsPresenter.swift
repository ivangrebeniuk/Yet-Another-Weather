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
    
    private let forecastService: IForecastService
    private let viewModelFactory: IWeatherDetailsViewModelFactory
    private let location: String
    weak var view: IWeatherDetailsView?
    
    // MARK: - Init
    
    init(
        weatherForecastService: IForecastService,
        viewModelFactory: IWeatherDetailsViewModelFactory,
        location: String
    ) {
        self.forecastService = weatherForecastService
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

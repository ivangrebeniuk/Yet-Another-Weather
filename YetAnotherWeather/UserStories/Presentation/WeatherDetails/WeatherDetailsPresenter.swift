//
//  WeatherDetailsPresenter.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 30.07.2024.
//

import Foundation

protocol IWeatherDetailsOutput: AnyObject {
    func didAddLocationToFavourites(location: String?)
}

protocol IWeatherDetailsPresenter {
    func viewDidLoad()

    func didTapAddButton()
}

final class WeatherDetailsPresenter {
    
    // Dependencies
    
    private let forecastService: IForecastService
    private let viewModelFactory: IWeatherDetailsViewModelFactory
    private let location: String
    private weak var output: IWeatherDetailsOutput?

    weak var view: IWeatherDetailsView?
    
    // MARK: - Init
    
    init(
        forecastService: IForecastService,
        viewModelFactory: IWeatherDetailsViewModelFactory,
        location: String,
        output: IWeatherDetailsOutput
    ) {
        self.forecastService = forecastService
        self.viewModelFactory = viewModelFactory
        self.location = location
        self.output = output
    }
}

// MARK: - IWeatherDetailsPresenter

extension WeatherDetailsPresenter: IWeatherDetailsPresenter {
    
    func viewDidLoad() {
        print("Открыли Детали погоды для \(location)")
    }

    func didTapAddButton() {
        output?.didAddLocationToFavourites(location: location)
    }
}

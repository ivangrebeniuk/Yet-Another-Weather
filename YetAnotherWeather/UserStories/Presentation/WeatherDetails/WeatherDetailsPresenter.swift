//
//  WeatherDetailsPresenter.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 30.07.2024.
//

import Foundation

protocol WeatherDetailsOutput: AnyObject {
    func didAddLocationToFavourites(location: String?)
    func didRequestToDismiss()
}

protocol IWeatherDetailsPresenter {
    func viewDidLoad()
    func didTapAddButton()
    func didRequestToDismiss()
}

final class WeatherDetailsPresenter {
    
    // Dependencies
    private let forecastService: IForecastService
    private let viewModelFactory: IWeatherDetailsViewModelFactory
    private let location: String
    private weak var output: WeatherDetailsOutput?

    weak var view: IWeatherDetailsView?
    
    // Models
    var forecastData: ForecastModel?
    
    // MARK: - Init
    
    init(
        forecastService: IForecastService,
        viewModelFactory: IWeatherDetailsViewModelFactory,
        location: String,
        output: WeatherDetailsOutput
    ) {
        self.forecastService = forecastService
        self.viewModelFactory = viewModelFactory
        self.location = location
        self.output = output
    }
    
    // MARK: - Private
    
    func getWeatherForecast() {
        forecastService.getWeatherForecast(for: location) { result in
            switch result {
            case .success(let result):
                DispatchQueue.main.async { [weak self] in
                    self?.forecastData = result
                    print("!!! \(result.currentWeather.location.name), \(result.currentWeather.location.country)")
                    print("!!! \(result.currentWeather.condition.text)")
                    result.forecastDays.forEach {
                        print("!!! Date \($0.date): Average Temp \($0.avgTemp)")
                    }
                }
            case .failure(let error):
                print("Ошибочка: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - IWeatherDetailsPresenter

extension WeatherDetailsPresenter: IWeatherDetailsPresenter {
    
    func viewDidLoad() {
        print("Открыли Детали погоды для \(location)")
        getWeatherForecast()
    }

    func didTapAddButton() {
        output?.didAddLocationToFavourites(location: location)
    }
    
    func didRequestToDismiss() {
        output?.didRequestToDismiss()
    }
}

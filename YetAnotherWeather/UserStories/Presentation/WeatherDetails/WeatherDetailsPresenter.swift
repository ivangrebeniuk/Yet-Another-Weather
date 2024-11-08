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
        forecastService.getWeatherForecast(for: location) { [weak self] result in
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.view?.startLoader()
                switch result {
                case .success(let forecastModel):
                    let viewModel = viewModelFactory.makeCurrentWeatherViewModel(
                        model: forecastModel
                    )
                    view?.updateView(wit: viewModel)
                case .failure(let error):
                    view?.showAlert()
                    print("Ошибочка: \(error.localizedDescription)")
                }
                self.view?.stopLoader()
            }
        }
    }
}

// MARK: - IWeatherDetailsPresenter

extension WeatherDetailsPresenter: IWeatherDetailsPresenter {
    
    func viewDidLoad() {
        getWeatherForecast()
    }

    func didTapAddButton() {
        output?.didAddLocationToFavourites(location: location)
    }
    
    func didRequestToDismiss() {
        output?.didRequestToDismiss()
    }
}

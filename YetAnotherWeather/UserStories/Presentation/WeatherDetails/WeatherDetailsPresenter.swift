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
    var isAddedToFavourites: Bool { get }
    func viewDidLoad()
    func didTapAddButton()
    func didRequestToDismiss()
}

final class WeatherDetailsPresenter {
    
    // Dependencies
    private let alertViewModelFactory: IAlertViewModelFactory
    private let forecastService: IForecastService
    private let viewModelFactory: IWeatherDetailsViewModelFactory
    private let feedbackGenerator: IFeedbackGeneratorService
    private let currentWeatherService: ICurrentWeatherService
    private let location: String
    private weak var output: WeatherDetailsOutput?

    weak var view: IWeatherDetailsView?
    
    // Models
    var forecastData: ForecastModel?
    
    // MARK: - Init
    
    init(
        alertViewModelFactory: IAlertViewModelFactory,
        forecastService: IForecastService,
        viewModelFactory: IWeatherDetailsViewModelFactory,
        feedbackGenerator: IFeedbackGeneratorService,
        currentWeatherService: ICurrentWeatherService,
        location: String,
        output: WeatherDetailsOutput
    ) {
        self.alertViewModelFactory = alertViewModelFactory
        self.forecastService = forecastService
        self.viewModelFactory = viewModelFactory
        self.feedbackGenerator = feedbackGenerator
        self.currentWeatherService = currentWeatherService
        self.location = location
        self.output = output
    }
    
    // MARK: - Private
    func getWeatherForecast() {
        view?.startLoader()
        forecastService.getWeatherForecast(for: location) { result in
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                switch result {
                case .success(let forecastModel):
                    let viewModel = viewModelFactory.makeCurrentWeatherViewModel(
                        model: forecastModel
                    )
                    view?.updateView(with: viewModel)
                case .failure(let error):
                    let alertModel = alertViewModelFactory.makeSingleButtonErrorAlert { [weak self] in
                        self?.didRequestToDismiss()
                    }
                    feedbackGenerator.generateFeedback(ofType: .notification(.error))
                    view?.showAlert(withModel: alertModel)
                    print("Ошибочка: \(error.localizedDescription)")
                }
                view?.stopLoader()
            }
        }
    }
}

// MARK: - IWeatherDetailsPresenter

extension WeatherDetailsPresenter: IWeatherDetailsPresenter {
    
    var isAddedToFavourites: Bool {
        currentWeatherService.cachedFavourites.contains(location) || currentWeatherService.cachedCurrecntLocation.contains(location)
    }
    
    func viewDidLoad() {
        getWeatherForecast()
    }

    func didTapAddButton() {
        feedbackGenerator.generateFeedback(ofType: .notification(.success))
        output?.didAddLocationToFavourites(location: location)
    }
    
    func didRequestToDismiss() {
        output?.didRequestToDismiss()
    }
}

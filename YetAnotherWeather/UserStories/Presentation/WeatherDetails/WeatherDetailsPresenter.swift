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
    func viewWillDisappear()
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
    private let isCurrentLocation: Bool
    private let lifeCycleHandlingService: ILifecycleHandlingService
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
        lifeCycleHandlingService: ILifecycleHandlingService,
        location: String,
        isCurrentLocation: Bool,
        output: WeatherDetailsOutput
    ) {
        self.alertViewModelFactory = alertViewModelFactory
        self.forecastService = forecastService
        self.viewModelFactory = viewModelFactory
        self.feedbackGenerator = feedbackGenerator
        self.currentWeatherService = currentWeatherService
        self.lifeCycleHandlingService = lifeCycleHandlingService
        self.location = location
        self.isCurrentLocation = isCurrentLocation
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
        currentWeatherService.cachedFavourites.contains(location) || isCurrentLocation
    }
    
    func viewDidLoad() {
        lifeCycleHandlingService.add(delegate: self)
        
        getWeatherForecast()
    }
    
    func viewWillDisappear() {
        lifeCycleHandlingService.remove(delegate: self)
    }

    func didTapAddButton() {
        feedbackGenerator.generateFeedback(ofType: .notification(.success))
        output?.didAddLocationToFavourites(location: location)
    }
    
    func didRequestToDismiss() {
        output?.didRequestToDismiss()
    }
}

// MARK: - ILifeCycleServiceDelegate

extension WeatherDetailsPresenter: ILifeCycleServiceDelegate {
    
    func notifyEnteredForeground() {
        getWeatherForecast()
    }
}

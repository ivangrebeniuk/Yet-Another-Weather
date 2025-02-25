//
//  WeatherDetailsPresenter.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 30.07.2024.
//

import Foundation

protocol WeatherDetailsOutput: AnyObject {
    func didAddLocationToFavourites(location: Location?)
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
    private let favouritesService: IFavouritesService
    private let identifier: String
    private let isCurrentLocation: Bool
    private let lifeCycleHandlingService: ILifecycleHandlingService
    private weak var output: WeatherDetailsOutput?
    weak var view: IWeatherDetailsView?
    
    // Models
    private var weatherDetailsViewModel: WeatherDetailsViewModel?

    // MARK: - Init
    
    init(
        alertViewModelFactory: IAlertViewModelFactory,
        forecastService: IForecastService,
        viewModelFactory: IWeatherDetailsViewModelFactory,
        feedbackGenerator: IFeedbackGeneratorService,
        favouritesService: IFavouritesService,
        lifeCycleHandlingService: ILifecycleHandlingService,
        identifier: String,
        isCurrentLocation: Bool,
        output: WeatherDetailsOutput
    ) {
        self.alertViewModelFactory = alertViewModelFactory
        self.forecastService = forecastService
        self.viewModelFactory = viewModelFactory
        self.feedbackGenerator = feedbackGenerator
        self.favouritesService = favouritesService
        self.lifeCycleHandlingService = lifeCycleHandlingService
        self.identifier = identifier
        self.isCurrentLocation = isCurrentLocation
        self.output = output
    }
    
    // MARK: - Private
    
    func getWeatherForecast() {
        view?.startLoader()
        forecastService.getWeatherForecast(for: identifier) { result in
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                switch result {
                case .success(let forecastModel):
                    let viewModel = viewModelFactory.makeCurrentWeatherViewModel(
                        model: forecastModel
                    )
                    weatherDetailsViewModel = viewModel
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
        favouritesService.cachedFavourites.forEach { print($0.name) }
        return favouritesService.cachedFavourites.contains { $0.id == identifier } || isCurrentLocation
    }
    
    func viewDidLoad() {
        lifeCycleHandlingService.add(delegate: self)
        getWeatherForecast()
    }

    func didTapAddButton() {
        guard let locationName = weatherDetailsViewModel?.currentWeatherViewModel.location else {
            return feedbackGenerator.generateFeedback(ofType: .notification(.error))
        }
        let timeStamp = Date.now.timeIntervalSince1970
        let location = Location(
            id: identifier,
            name: locationName,
            timeStamp: timeStamp
        )
        feedbackGenerator.generateFeedback(ofType: .notification(.success))
        output?.didAddLocationToFavourites(location: location)
    }
    
    func didRequestToDismiss() {
        output?.didRequestToDismiss()
    }
}

// MARK: - ILifeCycleServiceDelegate

extension WeatherDetailsPresenter: ILifeCycleServiceDelegate {
    
    func didEnterForeground() {
        getWeatherForecast()
    }
}

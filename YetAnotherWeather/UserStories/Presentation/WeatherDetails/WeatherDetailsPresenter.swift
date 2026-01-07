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
    private(set) var isAddedToFavourites: Bool
    
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
        isAddedToFavourites: Bool,
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
        self.isAddedToFavourites = isAddedToFavourites
        self.output = output
    }
    
    // MARK: - Private
    
    @MainActor
    func getWeatherForecast() async {
        do {
            view?.startLoader()
            let forecastModel = try await forecastService.getWeatherForecast(for: identifier)
            let viewModel = viewModelFactory.makeCurrentWeatherViewModel(
                model: forecastModel
            )
            weatherDetailsViewModel = viewModel
            view?.updateView(with: viewModel)
        } catch {
            let alertModel = alertViewModelFactory.makeSingleButtonErrorAlert { [weak self] in
                self?.didRequestToDismiss()
            }
            feedbackGenerator.generateFeedback(ofType: .notification(.error))
            view?.showAlert(withModel: alertModel)
        }
        
        view?.stopLoader()
    }
}

// MARK: - IWeatherDetailsPresenter

extension WeatherDetailsPresenter: IWeatherDetailsPresenter {
    
    func viewDidLoad() {
        lifeCycleHandlingService.add(delegate: self)
        Task {
            await getWeatherForecast()
        }
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
        Task {
            await getWeatherForecast()
        }
    }
}

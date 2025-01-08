//
//  AppAssembly.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 09.08.2024.
//

import CoreLocation
import Foundation
import SwiftyJSON
import SnapKit

final class AppAssembly {
    
    // Dependencies
    private lazy var urlRequestsFactory = URLRequestFactory()
    private lazy var networkService = NetworkService(session: URLSession.shared)
    private lazy var networkQueue = DispatchQueue(label: "ru.i.grebeniuk.serialNetworkQueue")
    private lazy var dataBaseQueue = DispatchQueue(label: "ru.i.grebeniuk.dataBaseQueue", qos: .userInitiated)
    private lazy var dateFormatter = CustomDateFormatter()
    private lazy var beaufortScaleResolver = BeaufortScaleResolver()
    private lazy var userDefaults = UserDefaults.standard
        
    // MARK: - FlowCoordinators
    
    var currentWeatherListFlowCoordinator: CurrentWeatherListFlowCoordinator {
        CurrentWeatherListFlowCoordinator(
            currentWeatherListAssembly: currentWeatherListAssembly,
            weatherDetailsAssembly: weatherDetailsAssembly,
            weatherDetailsFlowCoordinator: weatherDeatailsFlowCoordinator
        )
    }
    
    // MARK: - Private Presentation
    
    private var currentWeatherListAssembly: CurrentWeatherListAssembly {
        CurrentWeatherListAssembly(
            dateFormatter: dateFormatter,
            weatherNetworkService: currentWeatherService,
            searchResultAssembly: searchResultsAssembly,
            feedbackGeneratorService: feedbackGeneratorService,
            locationService: locationService,
            searchService: searchLocationsService
        )
    }
    
    private var searchResultsAssembly: SearchResultsAssembly {
        SearchResultsAssembly(
            searchLocationsService: searchLocationsService,
            forecastService: forecastService,
            feedbackGeneratorService: feedbackGeneratorService
        )
    }
    
    private var weatherDetailsAssembly: WeatherDetailsAssembly {
        WeatherDetailsAssembly(
            beaufortScaleResolver: beaufortScaleResolver,
            dateFormatter: dateFormatter,
            forecastService: forecastService,
            feedbackGeneratorService: feedbackGeneratorService,
            currentWeatherService: currentWeatherService
        )
    }
    
    private var weatherDeatailsFlowCoordinator: WeatherDetailsFlowCoordinator {
        WeatherDetailsFlowCoordinator(weatherDetailsAssembly: weatherDetailsAssembly)
    }
    
    // MARK: - Private Services
    
    private var currentWeatherService: ICurrentWeatherService {
        CurrentWeatherService(
            dataBaseQueue: dataBaseQueue,
            networkQueue: networkQueue,
            networkService: networkService,
            urlRequestsFactory: urlRequestsFactory,
            userDefaults: userDefaults
        )
    }
    
    private var searchLocationsService: ISearchLocationsService {
        SearchLocationsService(
            networkService: networkService,
            urlRequestsFactory: urlRequestsFactory
        )
    }
    
    private var forecastService: IForecastService {
        ForecastService(
            networkService: networkService,
            urlRequestsFactory: urlRequestsFactory
        )
    }
    
    private var feedbackGeneratorService: IFeedbackGeneratorService {
        FeedbackGeneratorService()
    }
    
    private var locationService: ILocationService {
        LocationService()
    }
}

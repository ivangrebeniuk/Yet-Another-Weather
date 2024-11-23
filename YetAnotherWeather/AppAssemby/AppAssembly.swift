//
//  AppAssembly.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 09.08.2024.
//

import Foundation
import SwiftyJSON
import SnapKit

final class AppAssembly {
    
    // Dependencies
    private lazy var urlRequestsFactory = URLRequestFactory()
    private lazy var networkService = NetworkService(session: URLSession.shared)
    private lazy var networkQueue = DispatchQueue(label: "ru.i.grebeniuk.serialNetworkQueue")
    private lazy var dateFormatter = CustomDateFormatter()
        
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
            weatherNetworkService: currentWeatherService,
            searchResultAssembly: searchResultsAssembly
        )
    }
    
    private var searchResultsAssembly: SearchResultsAssembly {
        SearchResultsAssembly(
            searchLocationsService: searchLocationsService,
            forecastService: forecastService
        )
    }
    
    private var weatherDetailsAssembly: WeatherDetailsAssembly {
        WeatherDetailsAssembly(
            dateFormatter: dateFormatter,
            forecastService: forecastService
        )
    }
    
    private var weatherDeatailsFlowCoordinator: WeatherDetailsFlowCoordinator {
        WeatherDetailsFlowCoordinator(weatherDetailsAssembly: weatherDetailsAssembly)
    }
    
    // MARK: - Private Services
    
    private var currentWeatherService: ICurrentWeatherService {
        CurrentWeatherService(
            networkQueue: networkQueue,
            networkService: networkService,
            urlRequestsFactory: urlRequestsFactory
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
}

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
    private let urlRequestsFactory = URLRequestFactory()
    private let networkService = NetworkService(session: URLSession.shared)
    private let networkQueue = DispatchQueue(label: "ru.i.grebeniuk.serialNetworkQueue")
    
    // MARK: - Presentation Assemblies
    
    private var currentWeatherListAssembly: CurrentWeatherListAssembly {
        return CurrentWeatherListAssembly(
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
        WeatherDetailsAssembly(weatherForecastService: forecastService)
    }
    
    private var weatherDeatailsFlowCoordinator: WeatherDetailsFlowCoordinator {
        WeatherDetailsFlowCoordinator(weatherDetailsAssembly: weatherDetailsAssembly)
    }
    
    // MARK: - FlowCoordinators
    
    var currentWeatherListFlowCoordinator: CurrentWeatherListFlowCoordinator {
        return CurrentWeatherListFlowCoordinator(
            currentWeatherListAssembly: currentWeatherListAssembly,
            weatherDetailsAssembly: weatherDetailsAssembly,
            weatherDetailsFlowCoordinator: weatherDeatailsFlowCoordinator
        )
    }
    
    // MARK: - Private
    
    private var currentWeatherService: ICurrentWeatherService {
        return CurrentWeatherService(
            networkQueue: networkQueue,
            networkService: networkService,
            urlRequestsFactory: urlRequestsFactory
        )
    }
    
    private var searchLocationsService: ISearchLocationsService {
        return SearchLocationsService(
            networkService: networkService,
            urlRequestsFactory: urlRequestsFactory
        )
    }
    
    private var forecastService: IForecastService {
        return ForecastService(
            networkService: networkService,
            urlRequestsFactory: urlRequestsFactory
        )
    }
}

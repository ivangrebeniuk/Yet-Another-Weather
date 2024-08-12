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
    
    var currentWeatherListAssembly: CurrentWeatherListAssembly {
        return CurrentWeatherListAssembly(
            weatherNetworkService: weatherNetworkService,
            searchResultAssembly: searchResultsAssembly
        )
    }
    
    var searchResultsAssembly: SearchResultsAssembly {
        SearchResultsAssembly(
            searchLocationsService: searchLocationsService,
            forecastService: weatherForecastService
        )
    }
    
    var weatherDetailsAssembly: WeatherDetailsAssembly {
        WeatherDetailsAssembly(weatherForecastService: weatherForecastService)
    }
    
    // MARK: - FlowCoordinators
    
    var currentWeatherListFlowCoordinator: CurrentWeatherListCoordinator {
        return CurrentWeatherListCoordinator(
            currentWeatherListAssembly: currentWeatherListAssembly,
            weatherDetailsAssembly: weatherDetailsAssembly
        )
    }
    
    // MARK: - Private
    
    private var weatherNetworkService: IWeatherNetworkService {
        return WeatherNetworkService(
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
    
    private var weatherForecastService: IWeatherForecastService {
        return WeatherForecastService(
            networkService: networkService,
            urlRequestsFactory: urlRequestsFactory
        )
    }
}

//
//  CurrentWeatherListAssembly.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 13.05.2024.
//

import UIKit

class CurrentWeatherListAssembly {
    
    // Dependencies
    let weatherNetworkService: IWeatherNetworkService
    let searchResultAssembly: SearchResultsAssembly
    
    init(weatherNetworkService: IWeatherNetworkService, searchResultAssembly: SearchResultsAssembly) {
        self.weatherNetworkService = weatherNetworkService
        self.searchResultAssembly = searchResultAssembly
    }
    
    func assemble(output: CurrentWeatherListOutput?) -> UIViewController {
        
        let presenter = CurrentWeatherListPresenter(
            weatherNetworkService: weatherNetworkService,
            output: output
        )
        
        let searchResultsViewController = searchResultAssembly.assemble(output: presenter)
        
        let viewController = CurrentWeatherListViewController(
            resultsViewController: searchResultsViewController,
            presenter: presenter
        )
        
        presenter.view = viewController
        return viewController
    }
}


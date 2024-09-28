//
//  CurrentWeatherListAssembly.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 13.05.2024.
//

import UIKit

class CurrentWeatherListAssembly {
    
    // Dependencies
    let currentWeatherService: ICurrentWeatherService
    let searchResultAssembly: SearchResultsAssembly
    
    init(
        weatherNetworkService: ICurrentWeatherService,
        searchResultAssembly: SearchResultsAssembly
    ) {
        self.currentWeatherService = weatherNetworkService
        self.searchResultAssembly = searchResultAssembly
    }
    
    func assemble(output: CurrentWeatherListOutput?) -> Module<CurrentWeatherListInput> {
        
        let presenter = CurrentWeatherListPresenter(
            currentWeatherService: currentWeatherService,
            output: output
        )
        
        let searchResultsViewController = searchResultAssembly.assemble(
            output: presenter
        )
        
        let viewController = CurrentWeatherListViewController(
            resultsViewController: searchResultsViewController,
            presenter: presenter
        )
        
        presenter.view = viewController
        return Module(viewController: viewController, moduleInput: presenter)
    }
}


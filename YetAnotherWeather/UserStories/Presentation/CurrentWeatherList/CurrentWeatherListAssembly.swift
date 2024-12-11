//
//  CurrentWeatherListAssembly.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 13.05.2024.
//

import UIKit

class CurrentWeatherListAssembly {
    
    // Dependencies
    private let dateFormatter: ICustomDateFormatter
    private let currentWeatherService: ICurrentWeatherService
    private let searchResultAssembly: SearchResultsAssembly
    
    // MARK: - Init
    
    init(
        dateFormatter: ICustomDateFormatter,
        weatherNetworkService: ICurrentWeatherService,
        searchResultAssembly: SearchResultsAssembly
    ) {
        self.dateFormatter = dateFormatter
        self.currentWeatherService = weatherNetworkService
        self.searchResultAssembly = searchResultAssembly
    }
    
    func assemble(output: CurrentWeatherListOutput?) -> Module<CurrentWeatherListInput> {
        
        let viewModelFactory = CurrentWeatherCellViewModelFactory(dateFormatter: dateFormatter)
        
        let presenter = CurrentWeatherListPresenter(
            currentWeatherService: currentWeatherService,
            viewModelFactory: viewModelFactory,
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


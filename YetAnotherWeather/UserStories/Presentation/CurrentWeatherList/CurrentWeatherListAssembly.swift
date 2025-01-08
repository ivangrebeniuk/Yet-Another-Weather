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
    private let feedbackGeneratorService: IFeedbackGeneratorService
    private let locationService: ILocationService
    private let searchService: ISearchLocationsService
    
    // MARK: - Init
    
    init(
        dateFormatter: ICustomDateFormatter,
        weatherNetworkService: ICurrentWeatherService,
        searchResultAssembly: SearchResultsAssembly,
        feedbackGeneratorService: IFeedbackGeneratorService,
        locationService: ILocationService,
        searchService: ISearchLocationsService
        
    ) {
        self.dateFormatter = dateFormatter
        self.currentWeatherService = weatherNetworkService
        self.searchResultAssembly = searchResultAssembly
        self.feedbackGeneratorService = feedbackGeneratorService
        self.locationService = locationService
        self.searchService = searchService
    }
    
    func assemble(output: CurrentWeatherListOutput?) -> Module<CurrentWeatherListInput> {
        
        let viewModelFactory = CurrentWeatherCellViewModelFactory(dateFormatter: dateFormatter)
        let alertViewModelFactory = AlertViewModelFactory()
        let presenter = CurrentWeatherListPresenter(
            alertViewModelFactory: alertViewModelFactory,
            currentWeatherService: currentWeatherService,
            viewModelFactory: viewModelFactory,
            feedbackGenerator: feedbackGeneratorService,
            locationService: locationService,
            searchService: searchService,
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


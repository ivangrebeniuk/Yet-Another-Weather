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
    private let lifecCycleService: ILifecycleHandlingService
    private let favouritesService: IFavouritesService
    
    // MARK: - Init
    
    init(
        dateFormatter: ICustomDateFormatter,
        weatherNetworkService: ICurrentWeatherService,
        searchResultAssembly: SearchResultsAssembly,
        feedbackGeneratorService: IFeedbackGeneratorService,
        locationService: ILocationService,
        searchService: ISearchLocationsService,
        lifecCycleService: ILifecycleHandlingService,
        favouritesService: IFavouritesService
    ) {
        self.dateFormatter = dateFormatter
        self.currentWeatherService = weatherNetworkService
        self.searchResultAssembly = searchResultAssembly
        self.feedbackGeneratorService = feedbackGeneratorService
        self.locationService = locationService
        self.searchService = searchService
        self.lifecCycleService = lifecCycleService
        self.favouritesService = favouritesService
    }
    
    @MainActor
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
            lifeCycleHandlingService: lifecCycleService,
            favouritesService: favouritesService,
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


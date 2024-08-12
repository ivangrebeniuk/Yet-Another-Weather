//
//  SearchResulsAssembly.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 19.07.2024.
//

import Foundation
import UIKit

final class SearchResultsAssembly {
    
    // Dependencies
    let searchLocationsService: ISearchLocationsService
    let forecastService: IWeatherForecastService
    
    init(
        searchLocationsService: ISearchLocationsService,
        forecastService: IWeatherForecastService
    ) {
        self.searchLocationsService = searchLocationsService
        self.forecastService = forecastService
    }
    
    func assemble(output: SearchResultsOutput?) -> UIViewController {
        
        let presenter = SearchResultsPresenter(
            searchLocationsService: searchLocationsService,
            output: output
        )
        
        let viewController = SearchResultsViewController(
            presenter: presenter
        )

        presenter.view = viewController
        
        return viewController
    }
}

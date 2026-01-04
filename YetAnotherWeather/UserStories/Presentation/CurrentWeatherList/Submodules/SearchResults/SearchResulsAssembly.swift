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
    private let searchLocationsService: ISearchLocationsService
    private let forecastService: IForecastService
    private let feedbackGeneratorService: IFeedbackGeneratorService
    
    init(
        searchLocationsService: ISearchLocationsService,
        forecastService: IForecastService,
        feedbackGeneratorService: IFeedbackGeneratorService
    ) {
        self.searchLocationsService = searchLocationsService
        self.forecastService = forecastService
        self.feedbackGeneratorService = feedbackGeneratorService
    }
    
    @MainActor
    func assemble(output: SearchResultsOutput?) -> UIViewController {
        
        let presenter = SearchResultsPresenter(
            searchLocationsService: searchLocationsService,
            feedbackGeneratorService: feedbackGeneratorService,
            output: output
        )
        
        let viewController = SearchResultsViewController(
            presenter: presenter
        )

        presenter.view = viewController
        
        return viewController
    }
}

//
//  SearchResulsAssembly.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 07.07.2024.
//

import Foundation
import UIKit

final class SearchResultsAssembly {
    
    // Dependencies
    let serviceAssembly: ServiceAssembly
    
    init(serviceAssembly: ServiceAssembly) {
        self.serviceAssembly = serviceAssembly
    }
    
    func assemble() -> UIViewController {
        
        let presenter = SearchResultsPresenter(
            weatherNetworkService: serviceAssembly.makeWeatherNetworkService()
        )
        
        let viewController = SearchResultsViewController(presenter: presenter)

        presenter.view = viewController
        
        return viewController
    }
}

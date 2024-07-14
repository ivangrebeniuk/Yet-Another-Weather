//
//  CurrentWeatherListAssembly.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 13.05.2024.
//

import UIKit

class CurrentWeatherListAssembly {
    
    // Dependencies
    let coordinator: ICoordinator
    let serviceAssembly: ServiceAssembly
    
    init(coordinator: ICoordinator,
         serviceAssembly: ServiceAssembly
    ) {
        self.coordinator = coordinator
        self.serviceAssembly = serviceAssembly
    }
    
    func assemble() -> UIViewController {
        
        let searchViewController = SearchResultsAssembly(serviceAssembly: serviceAssembly)
        
        let presenter = CurrentWeatherListPresenter(
            coordinator: coordinator,
            weatherNetworkService: serviceAssembly.makeWeatherNetworkService()
        )
        
        let viewController = CurrentWeatherListViewController(
            resultsViewController: searchViewController.assemble(),
            presenter: presenter
        )
        
        presenter.view = viewController
        return viewController
    }
}

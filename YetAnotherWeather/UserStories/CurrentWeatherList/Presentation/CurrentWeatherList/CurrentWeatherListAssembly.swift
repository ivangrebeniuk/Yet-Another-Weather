//
//  CurrentWeatherListAssembly.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 13.05.2024.
//

import UIKit

class CurrentWeatherListAssembly {
    
    let coordinator: ICoordinator
    
    init(coordinator: ICoordinator) {
        self.coordinator = coordinator
    }
    
    func assemble() -> UIViewController {
        let presenter = CurrentWeatherListPresenter(coordinator: coordinator)
        let viewController = CurrentWeatherListViewController(presenter: presenter)
        
        presenter.view = viewController
        return viewController
    }
}

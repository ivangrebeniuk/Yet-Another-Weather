//
//  WeatherListAssembly.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 13.05.2024.
//

import UIKit

class WeatherListAssembly {
    
    let coordinator: ICoordinator
    
    init(coordinator: ICoordinator) {
        self.coordinator = coordinator
    }
    
    func assemble() -> UIViewController {
        let presenter = WeatherListPresenter(coordinator: coordinator)
        let viewController = WeatherListViewController(presenter: presenter)
        
        presenter.view = viewController
        return viewController
    }
}

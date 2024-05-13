//
//  WeatherListAssembly.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 13.05.2024.
//

import UIKit

class WeatherListAssembly {
    
    func assemble() -> UIViewController {
        let presenter = WeatherListPresenter()
        let viewController = WeatherListViewController(presenter: presenter)
        
        presenter.view = viewController
        return viewController
    }
}

//
//  CurrentWeatherListCoordinator.swift
//  YetAnotherWeather
//
//  Created by Иван Гребенюк on 19.05.2024.
//

import Foundation
import UIKit

protocol IWeathreListCoordinator: ICoordinator {}

final class WeatherListCoordinator: IWeathreListCoordinator {
    
    var childrenCoordinators = [ICoordinator]()
    
    let navigationController: UINavigationController
    
    let serviceAssembly: ServiceAssembly
    
    init(
        navigationController: UINavigationController,
         serviceAssembly: ServiceAssembly
    ) {
        self.navigationController = navigationController
        self.serviceAssembly = serviceAssembly
    }
    
    func start() {
        let assembly = CurrentWeatherListAssembly(
            coordinator: self,
            serviceAssembly: serviceAssembly
        )
        let viewController = assembly.assemble()
        
        navigationController.pushViewController(viewController, animated: true)
    }
}

//
//  WeatherListCoordinator.swift
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
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let assembly = WeatherListAssembly(coordinator: self)
        let viewController = assembly.assemble()
        
        navigationController.pushViewController(viewController, animated: true)
    }
}

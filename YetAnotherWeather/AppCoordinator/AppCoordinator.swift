//
//  AppCoordinator.swift
//  YetAnotherWeather
//
//  Created by Иван Гребенюк on 19.05.2024.
//

import Foundation
import UIKit

final class AppCoordinator: ICoordinator {
    
    let serviceAssembly = ServiceAssembly()
    
    var childrenCoordinators = [ICoordinator]()
    
    var window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func start() {
        let navigationController = UINavigationController()
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        let coordinator = WeatherListCoordinator(
            navigationController: navigationController,
            serviceAssembly: serviceAssembly
        )
        coordinator.start()
    }
}

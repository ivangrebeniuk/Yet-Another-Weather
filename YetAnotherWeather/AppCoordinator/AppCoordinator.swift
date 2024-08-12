//
//  AppCoordinator.swift
//  YetAnotherWeather
//
//  Created by Иван Гребенюк on 19.05.2024.
//

import Foundation
import UIKit

final class AppCoordinator {
    
    private let appAssembly = AppAssembly()
    private lazy var weatherListFlowCoordinator = appAssembly.currentWeatherListFlowCoordinator
        
    var window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func start() {
        let navigationController = UINavigationController()
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        weatherListFlowCoordinator.start(with: navigationController)
    }
}

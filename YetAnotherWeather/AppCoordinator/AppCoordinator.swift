//
//  AppCoordinator.swift
//  YetAnotherWeather
//
//  Created by Иван Гребенюк on 19.05.2024.
//

import Foundation
import UIKit

final class AppCoordinator {
    
    private let appAssembly: AppAssembly
    private lazy var currentWeatherListFlowCoordinator = appAssembly.currentWeatherListFlowCoordinator
        
    var window: UIWindow
    
    init(
        window: UIWindow,
        appDelegate: IAppDelegate
    ) {
        self.window = window
        self.appAssembly = AppAssembly(appDelegate: appDelegate)
    }
    
    func start() {
        let navigationController = UINavigationController()
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        currentWeatherListFlowCoordinator.start(with: navigationController)
    }
}

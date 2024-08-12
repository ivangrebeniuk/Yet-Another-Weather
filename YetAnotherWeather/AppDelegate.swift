//
//  AppDelegate.swift
//  YetAnotherWeather
//
//  Created by Иван Гребенюк on 13.05.2024.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private var appCoordinator: AppCoordinator?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        
        appCoordinator = AppCoordinator(window: window)
        appCoordinator?.start()

        window.makeKeyAndVisible()
        self.window = window
        return true
    }
}


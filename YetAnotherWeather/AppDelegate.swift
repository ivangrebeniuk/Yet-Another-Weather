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

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = WeatherListAssembly().assemble()
        window.makeKeyAndVisible()
        self.window = window
        // Override point for customization after application launch.
        return true
    }
}


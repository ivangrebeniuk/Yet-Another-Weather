//
//  AppDelegate.swift
//  YetAnotherWeather
//
//  Created by Иван Гребенюк on 13.05.2024.
//

import UIKit

protocol AppLifeCycleDelegate: AnyObject {
    
    var willEnterForegroundNotification: (() -> Void)? { get set }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, AppLifeCycleDelegate {

    var window: UIWindow?
    private var appCoordinator: AppCoordinator?
    
    var willEnterForegroundNotification: (() -> Void)?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        
        appCoordinator = AppCoordinator(
            window: window,
            appLifeCycleDelegate: self
        )
        
        appCoordinator?.start()

        window.makeKeyAndVisible()
        self.window = window
        return true
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        willEnterForegroundNotification?()
    }
}

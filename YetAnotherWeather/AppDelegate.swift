//
//  AppDelegate.swift
//  YetAnotherWeather
//
//  Created by Иван Гребенюк on 13.05.2024.
//

import UIKit

protocol IAppLifeCycleDelegate: AnyObject {
    
    func appWillEnterForeground()
}

protocol IAppDelegate: AnyObject {
    
    var delegate: IAppLifeCycleDelegate? { get set }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, IAppDelegate {

    var window: UIWindow?
    private var appCoordinator: AppCoordinator?
    
    // IAppDelegate
    weak var delegate: IAppLifeCycleDelegate?
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        
        appCoordinator = AppCoordinator(
            window: window,
            appDelegate: self
        )
        
        appCoordinator?.start()

        window.makeKeyAndVisible()
        self.window = window
        return true
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        delegate?.appWillEnterForeground()
    }
}

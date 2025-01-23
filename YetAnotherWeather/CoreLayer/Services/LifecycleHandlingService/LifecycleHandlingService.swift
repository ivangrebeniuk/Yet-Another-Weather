//
//  LifecycleHandlingService.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 18.01.2025.
//

import Foundation

protocol ILifecycleHandlingService: AnyObject {
        
    func add(delegate: some ILifeCycleServiceDelegate)
    
    func remove(delegate: ILifeCycleServiceDelegate)
}

protocol ILifeCycleServiceDelegate: AnyObject {
    
    func notifyEnteredForeground()
}

final class LifecycleHandlingService: ILifecycleHandlingService {
    
    private static let delegatesList = OptimizedDelegatesList<ILifeCycleServiceDelegate>()
    private weak var appLifecycleDelegate: AppLifeCycleDelegate?
    weak var delegate: ILifeCycleServiceDelegate?
    
    // MARK: - Init
    
    init(appLifecycleDelegate: AppLifeCycleDelegate? = nil) {
        self.appLifecycleDelegate = appLifecycleDelegate
        setUpLifecycleHandler()
    }
    
    // MARK: - Public: Delegates
    
    /// Подписывает слушателя на уведомление о выходе в foreground
    public func add(delegate: some ILifeCycleServiceDelegate) {
        Self.delegatesList.addDelegate(weakify(delegate))
    }

    /// Удаляет слушателя
    public func remove(delegate: ILifeCycleServiceDelegate) {
        Self.delegatesList.removeDelegate(delegate)
    }
    
    // MARK: - Private
    
    private func setUpLifecycleHandler() {
        appLifecycleDelegate?.willEnterForegroundNotification = { [weak self] in
            self?.handleEventWillEneterForeground()
        }
    }
    
    private func handleEventWillEneterForeground() {
        DispatchQueue.main.async {
            Self.delegatesList.forEach {
                $0.notifyEnteredForeground()
            }
        }
    }
}

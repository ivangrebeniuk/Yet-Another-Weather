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
    
    // MARK: - ILifecycleHandlingService
    
    func add(delegate: some ILifeCycleServiceDelegate) {
        Self.delegatesList.addDelegate(weakify(delegate))
    }

    func remove(delegate: ILifeCycleServiceDelegate) {
        Self.delegatesList.removeDelegate(delegate)
    }
    
    // MARK: - Private

    private func handleEventWillEneterForeground() {
        DispatchQueue.main.async {
            Self.delegatesList.forEach {
                $0.notifyEnteredForeground()
            }
        }
    }
}

// MARK: - IAppLifeCycleDelegate

extension LifecycleHandlingService: IAppLifeCycleDelegate {
    
    func appWillEnterForeground() {
        handleEventWillEneterForeground()
    }
}

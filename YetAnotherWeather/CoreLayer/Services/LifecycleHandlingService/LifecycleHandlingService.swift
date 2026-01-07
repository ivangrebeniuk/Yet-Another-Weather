//
//  LifecycleHandlingService.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 18.01.2025.
//

import Foundation

protocol ILifecycleHandlingService: AnyObject {
        
    func add(delegate: some ILifeCycleServiceDelegate)
}

protocol ILifeCycleServiceDelegate: AnyObject {
    
    func didEnterForeground()
}

final class LifecycleHandlingService: ILifecycleHandlingService {
    
    private static let delegatesList = OptimizedDelegatesList<ILifeCycleServiceDelegate>()
    
    // MARK: - ILifecycleHandlingService
    
    func add(delegate: some ILifeCycleServiceDelegate) {
        Self.delegatesList.addDelegate(weakify(delegate))
    }
    
    // MARK: - Private
    
    private func handleEventWillEnterForeground() {
        Task { @MainActor in
            Self.delegatesList.forEach {
                $0.didEnterForeground()
            }
        }
    }
}

// MARK: - IAppLifeCycleDelegate

extension LifecycleHandlingService: IAppLifeCycleDelegate {
    
    func appWillEnterForeground() {
        handleEventWillEnterForeground()
    }
}

//
//  AlertMessageViewModelFactory.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 10.11.2024.
//

import Foundation

private extension String {
    
    static let errorAlertTitle = "Something went wrong"
    static let errorAlertMessage = "Try again later"
    static let alertButtonText = "OK"
}

protocol IAlertMessageViewModelFactory: AnyObject {
    
    func makeSingleButtonErrorAlert(
        actionHandler: (() -> Void)?
    ) -> SingleButtonAlertViewModel
}

// MARK: - IAlertMessageViewModelFactory

final class AlertMessageViewModelFactory: IAlertMessageViewModelFactory {
    
    func makeSingleButtonErrorAlert(
        actionHandler: (() -> Void)?
    ) -> SingleButtonAlertViewModel {
        SingleButtonAlertViewModel(
            title: .errorAlertTitle,
            message: .errorAlertMessage,
            buttonText: .alertButtonText,
            actionHandler: actionHandler
        )
    }
}

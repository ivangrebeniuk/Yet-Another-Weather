//
//  UIAlertController+Alert.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 10.11.2024.
//

import Foundation
import UIKit

extension UIAlertController {
        
    static func makeSingleButtonAlert(action: (() -> Void)?) -> UIAlertController {
        
        let model = AlertMessageViewModelFactory().makeSingleButtonErrorAlert(actionHandler: action)
        
        let alertMessage = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert
        )
        
        let action = UIAlertAction(
            title: model.buttonText,
            style: .cancel) { _ in
                model.actionHandler?()
            }
        
        alertMessage.addAction(action)
        
        return alertMessage
    }
}
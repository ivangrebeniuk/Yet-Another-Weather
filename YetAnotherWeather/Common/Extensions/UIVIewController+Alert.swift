//
//  UIVIewController+Alert.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 08.11.2024.
//

import Foundation
import UIKit

extension UIViewController {
    
    func makeAlertMessage(
        with title: String,
        message: String?,
        firstButtonText: String,
        firstButtonStyle: UIAlertAction.Style,
        secondButtonText: String? = nil,
        secondButtonStyle: UIAlertAction.Style? = nil,
        actionHandler: (() -> Void)?
    ) -> UIAlertController {
        let alertMessage = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        let action = UIAlertAction(
            title: firstButtonText,
            style: firstButtonStyle) { _ in
                actionHandler?()
            }
        
        alertMessage.addAction(action)
        
        return alertMessage
    }
    
    func showAlert(_ alertMessage: UIAlertController) {
        self.present(alertMessage, animated: true)
    }
}

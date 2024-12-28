//
//  FeedbackGeneratorService.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 21.12.2024.
//

import Foundation
import UIKit

enum FeedbackType {
    case notification(UINotificationFeedbackGenerator.FeedbackType)
    case impact(UIImpactFeedbackGenerator.FeedbackStyle)
    case selectionChanged
}

protocol IFeedbackGeneratorService: Any {
    
    func generateFeedback(ofType type: FeedbackType)
}

final class FeedbackGeneratorService: IFeedbackGeneratorService {
    
    // Dependencies
    private lazy var notificationGenerator = UINotificationFeedbackGenerator()
    private lazy var impactGenerator = UIImpactFeedbackGenerator(style: .medium)
    private lazy var selectionGenerator = UISelectionFeedbackGenerator()

    // MARK: -  IFeedbackGeneratorService
    
    func generateFeedback(ofType type: FeedbackType) {
        switch type {
        case .notification(let feedbackType):
            notificationGenerator.notificationOccurred(feedbackType)
        case .impact:
            impactGenerator.impactOccurred()
        case .selectionChanged:
            selectionGenerator.selectionChanged()
        }
    }
}


//
//  SingleButtonAlertViewModel.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 10.11.2024.
//

import Foundation

struct SingleButtonAlertViewModel {
    let title: String
    let message: String?
    let buttonText: String
    let actionHandler: (() -> Void)?
}

//
//  CurrentWeatherCellView.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 01.06.2024.
//

import UIKit

final class CurrentWeatherCellView: UIView {
    
}

// MARK: - ConfigurableView

extension CurrentWeatherCellView: ConfigurableView {
    
    struct Model {
        let locationName: String
        let tempreture: String
        let localTime: String
        let icon: UIImage
    }
    
    func configure(with model: Model) {
        print("view must be configured here")
    }
}

//
//  CurrentWeatherView.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 12.10.2024.
//

import Foundation
import UIKit

private extension UIColor {
    static let inversedTitleColor = UIColor(
        dynamicProvider: {
            $0.userInterfaceStyle == .dark ? .black : .white
        }
    )
}

final class CurrentWeatherView: UIView {
    
    // UI
    private var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillProportionally
        return stackView
    }()
    
    private var locationLabel: UILabel = {
        let label = UILabel()
        label.textColor = .inversedTitleColor
        label.font = UIFont.systemFont(ofSize: CGFloat(37), weight: .regular)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var currentTempLabel: UILabel = {
        let label = UILabel()
        label.textColor = .inversedTitleColor
        label.font = UIFont.systemFont(ofSize: CGFloat(102), weight: .thin)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var conditionsLabel: UILabel = {
        let label = UILabel()
        label.textColor = .inversedTitleColor
        label.font = UIFont.systemFont(ofSize: CGFloat(24), weight: .regular)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var highAndLowLabel: UILabel = {
        let label = UILabel()
        label.textColor = .inversedTitleColor
        label.font = UIFont.systemFont(ofSize: CGFloat(21), weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Private
    
    private func setUpUI() {
        self.addSubview(stackView)
        stackView.addArrangedSubview(locationLabel)
        stackView.addArrangedSubview(currentTempLabel)
        stackView.addArrangedSubview(conditionsLabel)
        stackView.addArrangedSubview(highAndLowLabel)
        
        stackView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(8)
        }
        
        locationLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
        }
        
        currentTempLabel.snp.makeConstraints {
            //$0.top.equalTo(locationLabel.snp.bottom)
            $0.centerX.equalToSuperview()
            $0.leading.trailing.equalToSuperview()

        }
        
        conditionsLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
        }
        
        highAndLowLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
        }
    }
}

// MARK: - ConfigurableView

extension CurrentWeatherView: ConfigurableView {
    
//    struct Model {
//        let location: String
//        let currentTemp: String
//        let conditions: String
//        let minTemp: String
//        let maxTemp: String
//    }
    
    func configure(with model: WeatherDetailsViewModel.CurrentWeatherViewModel) {
        self.backgroundColor = UIColor.systemGray3
        locationLabel.text = model.location
        currentTempLabel.text = model.currentTemp
        conditionsLabel.text = model.conditions
        highAndLowLabel.text = "H:\(model.maxTemp)  L:\(model.minTemp)"
    }
}

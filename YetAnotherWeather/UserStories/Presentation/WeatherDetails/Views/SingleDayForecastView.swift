//
//  SingleDayForecastView.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 16.11.2024.
//

import Foundation
import SnapKit
import Kingfisher
import UIKit

private extension String {
    static let lowTempLetter = "L:"
    static let highTempLetter = "H:"
}

private extension CGFloat {
    static let dayLabelMultiplier = 0.35
    static let iconAndRainMultiplier = 0.2
    static let lowTempLabelMultiplier = 0.125
    static let highTempLabelMultiplier = 0.125
    static let lowLetterLabelMultiplier = 0.1
    static let hightLetterLabelMultiplier = 0.1
}

final class SingleDayForecastView: UIView {
    
    // UI
    private let dayLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: CGFloat(22), weight: .regular)
        label.textColor = .white
        label.textAlignment = .left
        return label
    }()
    
    private let imageView = UIImageView()
    
    private let rainFallChanceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: CGFloat(15), weight: .regular)
        label.textColor = UIColor(red: 0.51, green: 0.81, blue: 0.98, alpha: 1.00)
        return label
    }()
    
    private let lowLetterLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: CGFloat(22), weight: .regular)
        label.alpha = 0.6
        label.textColor = .white
        label.text = .lowTempLetter
        return label
    }()
    
    private let highLetterLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: CGFloat(22), weight: .regular)
        label.textColor = .white
        label.text = .highTempLetter
        return label
    }()
    
    private let lowTempLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: CGFloat(22), weight: .regular)
        label.alpha = 0.5
        label.textColor = .white
        return label
    }()
    
    private let highTempLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: CGFloat(22), weight: .regular)
        label.textColor = .white
        return label
    }()
    
    private let imageAndRainStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .center
        return stackView
    }()
    
    private let forecastHorizontalStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        return stackView
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpUI()
        setUpConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private
    
    private func setUpUI() {
        addSubview(forecastHorizontalStack)
        
        forecastHorizontalStack.addArrangedSubview(dayLabel)
        forecastHorizontalStack.addArrangedSubview(imageAndRainStack)
        
        forecastHorizontalStack.addArrangedSubview(lowLetterLabel)
        forecastHorizontalStack.addArrangedSubview(lowTempLabel)
        
        forecastHorizontalStack.addArrangedSubview(highLetterLabel)
        forecastHorizontalStack.addArrangedSubview(highTempLabel)
        
        imageAndRainStack.addArrangedSubview(imageView)
        imageAndRainStack.addArrangedSubview(rainFallChanceLabel)
    }
    
    private func setUpConstraints() {
        forecastHorizontalStack.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        imageView.snp.makeConstraints {
            $0.size.equalTo(32)
        }
        
        let subviewsWidthDict: [UIView: CGFloat] = [
            dayLabel: CGFloat(.dayLabelMultiplier),
            imageAndRainStack: CGFloat(.iconAndRainMultiplier),
            lowLetterLabel: CGFloat(.lowLetterLabelMultiplier),
            lowTempLabel: CGFloat(.lowTempLabelMultiplier),
            highLetterLabel: CGFloat(.hightLetterLabelMultiplier),
            highTempLabel: CGFloat(.highTempLabelMultiplier)
        ]
        
        for (view, multiplier) in subviewsWidthDict {
            view.snp.makeConstraints {
                $0.width.equalToSuperview().multipliedBy(multiplier)
            }
        }
    }
}

// MARK: - ConfigurableView

extension SingleDayForecastView: ConfigurableView {
    
    struct Model {
        let day: String
        let imageURL: URL
        let rainFallChance: String?
        let lowTemp: String
        let highTemp: String
    }
    
    func configure(with model: SingleDayForecastView.Model) {
        imageView.contentMode = .scaleAspectFit
        dayLabel.text = model.day
        imageView.kf.setImage(with: model.imageURL)
        rainFallChanceLabel.isHidden = model.rainFallChance == nil
        rainFallChanceLabel.text = model.rainFallChance
        lowTempLabel.text = model.lowTemp
        highTempLabel.text = model.highTemp
    }
}

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
    
    // lowLabel и hightLabel разбить на две вью: отельно буква и знак ":" и отдельно температура
//    - написать отдельную вью под Temperature (L/H и строка под температуру)
//    - сделать адаптивную верстку с процентным соотношением как обсуждали
//    - переделать конфигурацию чтобы не было 3 захордкоженых вьюшек под каждый день
//    - сделать заблюреный фон под все это дело
    
    private let lowLetterLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: CGFloat(22), weight: .regular)
        label.alpha = 0.5
        label.textColor = .white
        return label
    }()
    
    private let highLetterLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: CGFloat(22), weight: .regular)
        label.textColor = .white
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
    
    private let bottomBorder: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray5
        return view
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
        addSubview(bottomBorder)
        
        imageAndRainStack.addArrangedSubview(imageView)
        imageAndRainStack.addArrangedSubview(rainFallChanceLabel)
        
        forecastHorizontalStack.addArrangedSubview(dayLabel)
        forecastHorizontalStack.addArrangedSubview(imageAndRainStack)
        
        forecastHorizontalStack.addArrangedSubview(lowLetterLabel)
        forecastHorizontalStack.addArrangedSubview(lowTempLabel)
        
        forecastHorizontalStack.addArrangedSubview(highLetterLabel)
        forecastHorizontalStack.addArrangedSubview(highTempLabel)
        
    }
    
    private func setUpConstraints() {
        bottomBorder.snp.makeConstraints {
            $0.height.equalTo(0.5)
            $0.bottom.equalTo(forecastHorizontalStack.snp.bottom)
            $0.leading.trailing.equalToSuperview().inset(
                UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 6)
            )
        }
        
        imageView.snp.makeConstraints {
            $0.width.equalTo(32)
            $0.height.equalTo(24)
        }
        
        forecastHorizontalStack.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        dayLabel.snp.makeConstraints {
            $0.width.equalToSuperview().multipliedBy(0.3)
        }
        
        imageAndRainStack.snp.makeConstraints {
            $0.width.equalToSuperview().multipliedBy(0.2)
        }
        
        lowLetterLabel.snp.makeConstraints {
            $0.width.equalToSuperview().multipliedBy(0.1)
        }
        
        lowTempLabel.snp.makeConstraints {
            $0.width.equalToSuperview().multipliedBy(0.15)
        }
        
        highLetterLabel.snp.makeConstraints {
            $0.width.equalToSuperview().multipliedBy(0.1)
        }
        
        highTempLabel.snp.makeConstraints {
            $0.width.equalToSuperview().multipliedBy(0.15)
        }
    }
}

// MARK: - ConfigurableView

extension SingleDayForecastView: ConfigurableView {
    
    struct Model {
        let day: String
        let imageURL: URL
        let rainFallChance: String?
        let lowLetter: String
        let lowTemp: String
        let highLetter: String
        let highTemp: String
    }
    
    func configure(with model: SingleDayForecastView.Model) {
        imageView.contentMode = .scaleAspectFill
        dayLabel.text = model.day
        imageView.kf.setImage(with: model.imageURL)
        rainFallChanceLabel.text = model.rainFallChance
        lowLetterLabel.text = model.lowLetter
        lowTempLabel.text = model.lowTemp
        highLetterLabel.text = model.highLetter
        highTempLabel.text = model.highTemp
    }
}

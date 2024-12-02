//
//  ForecastStackView.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 19.11.2024.
//

import Foundation
import UIKit

final class ForecastView: UIView {
    
    // UI
    private var daysStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 6
        return stackView
    }()
    
    private var titleStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 6
        stackView.alpha = 0.6
        return stackView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: CGFloat(15), weight: .medium)
        label.textColor = .white
        return label
    }()
        
    private let titleIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.init(systemName: "calendar")
        imageView.tintColor = .white
        return imageView
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
        addSubview(titleStackView)
        addSubview(daysStackView)
        
        titleStackView.addArrangedSubview(titleIcon)
        titleStackView.addArrangedSubview(titleLabel)
    }
    
    private func setUpConstraints() {
        titleStackView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(8)
            $0.leading.trailing.equalToSuperview().inset(12)
        }
        
        titleIcon.snp.makeConstraints {
            $0.size.equalTo(17)
        }
        
        daysStackView.snp.makeConstraints {
            $0.top.equalTo(titleStackView.snp.bottom).offset(6)
            $0.bottom.equalToSuperview().inset(6)
            $0.leading.trailing.equalToSuperview().inset(12)
        }
    }
}

// MARK: - ConfigurableVIew

extension ForecastView: ConfigurableView {
    
    struct Model {
        let forecastTitle: String
        let forecasts: [SingleDayForecastView.Model]
    }
    
    func configure(with model: ForecastView.Model) {
        titleLabel.text = model.forecastTitle
        
        daysStackView.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }
        
        var counter = 0
        let amountOfModels = model.forecasts.count
        for model in model.forecasts {
            let view = SingleDayForecastView()
            let bottomLineView = BottomLineView(configuration: .default)
            view.configure(with: model)
            daysStackView.addArrangedSubview(view)
            counter += 1
            
            if counter < amountOfModels {
                daysStackView.addArrangedSubview(bottomLineView)
            }
        }
    }
}
    

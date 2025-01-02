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
    private let headerView = WidgetHeaderView()
    private var daysStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 6
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
        addSubview(headerView)
        addSubview(daysStackView)
    }
    
    private func setUpConstraints() {
        headerView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview().inset(12)
        }
        
        daysStackView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom).offset(6)
            $0.bottom.leading.trailing.equalToSuperview().inset(12)
        }
    }
}

// MARK: - ConfigurableVIew

extension ForecastView: ConfigurableView {
    
    struct Model {
        let forecastHeader: WidgetHeaderView.Model
        let forecasts: [SingleDayForecastView.Model]
    }
    
    func configure(with model: ForecastView.Model) {
        headerView.configure(with: model.forecastHeader)
        
        daysStackView.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }
        
        let amountOfModels = model.forecasts.count
        for (index, model) in model.forecasts.enumerated() {
            let view = SingleDayForecastView()
            let bottomLineView = BottomLineView(configuration: .default)
            view.configure(with: model)
            daysStackView.addArrangedSubview(view)
            
            if index < amountOfModels - 1 {
                daysStackView.addArrangedSubview(bottomLineView)
            }
        }
    }
}
    

//
//  HourlyForecastView.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 30.12.2024.
//

import Foundation
import SnapKit
import UIKit

final class HourlyForecastView: UIView {
    
    // UI
    private let headerView = WidgetHeaderView()
    
    private let scrollView = UIScrollView()
    
    private var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 30
        return stackView
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpUI()
        setUpScrollView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private
    
    private func setUpScrollView() {
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isScrollEnabled = true
        scrollView.alwaysBounceVertical = false
    }
    
    func setUpUI() {
        addSubview(headerView)
        headerView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview().inset(12)
        }
        
        addSubview(scrollView)
        scrollView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom).offset(12)
            $0.bottom.leading.trailing.equalToSuperview().inset(12)
            $0.height.greaterThanOrEqualTo(110)
        }
        
        scrollView.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
        }
    }
}

// MARK: - ConfigurableView

extension HourlyForecastView: ConfigurableView {
    
    struct Model {
        let headerModel: WidgetHeaderView.Model
        let forecasts: [SingleHourView.Model]
    }
    
    func configure(with model: Model) {
        headerView.configure(with: model.headerModel)
        
        stackView.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }
        
        for model in model.forecasts {
            let view = SingleHourView()
            view.configure(with: model)
            stackView.addArrangedSubview(view)
        }
    }
}

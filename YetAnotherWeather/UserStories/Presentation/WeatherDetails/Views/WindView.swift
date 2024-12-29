//
//  WindView.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 23.11.2024.
//

import Foundation
import SnapKit
import UIKit

final class WindView: UIView {

    // UI
    private let widgetHeaderView = WidgetHeaderView()
    private let windView = WindParametersView()
    private let gustsView = WindParametersView()
    private let windDirectionView = WindParametersView()
    
    private let containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 12
        return stackView
    }()
        
    private let summaryStatusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: CGFloat(18), weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let summaryDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: CGFloat(16), weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let summaryStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        return stackView
    }()
    
    private let windStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 6
        stackView.distribution = .equalCentering
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
        let windBottomLine = BottomLineView(configuration: .default)
        let gustsBottomLine = BottomLineView(configuration: .default)        
        
        addSubview(widgetHeaderView)
        addSubview(containerStackView)
        containerStackView.addArrangedSubview(windStackView)
        containerStackView.addArrangedSubview(summaryStackView)
        
        summaryStackView.addArrangedSubview(summaryStatusLabel)
        summaryStackView.addArrangedSubview(summaryDescriptionLabel)
        
        windStackView.addArrangedSubview(windView)
        windStackView.addArrangedSubview(windBottomLine)
        windStackView.addArrangedSubview(gustsView)
        windStackView.addArrangedSubview(gustsBottomLine)
        windStackView.addArrangedSubview(windDirectionView)
    }
    
    private func setUpConstraints() {
        widgetHeaderView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview().inset(12)
        }
        
        containerStackView.snp.makeConstraints {
            $0.top.equalTo(widgetHeaderView.snp.bottom).offset(6)
            $0.bottom.leading.trailing.equalToSuperview().inset(12)
        }
    }
}

// MARK: - ConfigurableView

extension WindView: ConfigurableView {
    
    struct Model {
        let windWidgetHeader: WidgetHeaderView.Model
        let summaryStatus: String
        let summaryDescription: String
        let wind: WindParametersView.Model
        let gusts: WindParametersView.Model
        let windDirection: WindParametersView.Model
    }
    
    func configure(with model: WindView.Model) {
        widgetHeaderView.configure(with: model.windWidgetHeader)
        summaryStatusLabel.text = model.summaryStatus
        summaryDescriptionLabel.text = model.summaryDescription
        windView.configure(with: model.wind)
        gustsView.configure(with: model.gusts)
        windDirectionView.configure(with: model.windDirection)
    }
}

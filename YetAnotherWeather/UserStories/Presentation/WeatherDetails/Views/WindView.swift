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
        label.numberOfLines = 0
        return label
    }()
    
    private let titleIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.init(systemName: "wind")
        imageView.tintColor = .white
        return imageView
    }()
        
    private let summaryStatusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: CGFloat(22), weight: .medium)
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
        
        addSubview(titleStackView)
        addSubview(containerStackView)
        containerStackView.addArrangedSubview(windStackView)
        containerStackView.addArrangedSubview(summaryStackView)
        
        titleStackView.addArrangedSubview(titleIcon)
        titleStackView.addArrangedSubview(titleLabel)
        
        summaryStackView.addArrangedSubview(summaryStatusLabel)
        summaryStackView.addArrangedSubview(summaryDescriptionLabel)
        
        windStackView.addArrangedSubview(windView)
        windStackView.addArrangedSubview(windBottomLine)
        windStackView.addArrangedSubview(gustsView)
        windStackView.addArrangedSubview(gustsBottomLine)
        windStackView.addArrangedSubview(windDirectionView)
    }
    
    private func setUpConstraints() {
        titleStackView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(8)
            $0.leading.trailing.equalToSuperview().inset(12)
        }
        
        titleIcon.snp.makeConstraints {
            $0.size.equalTo(17)
        }
        
        containerStackView.snp.makeConstraints {
            $0.top.equalTo(titleStackView.snp.bottom).offset(6)
            $0.bottom.equalToSuperview().inset(6)
            $0.leading.trailing.equalToSuperview().inset(12)
        }
    }
}

// MARK: - ConfigurableView

extension WindView: ConfigurableView {
    
    struct Model {
        let title: String
        let summaryStatus: String
        let summaryDescription: String
        let wind: WindParametersView.Model
        let gusts: WindParametersView.Model
        let windDirection: WindParametersView.Model
    }
    
    func configure(with model: WindView.Model) {
        titleLabel.text = model.title
        summaryStatusLabel.text = model.summaryStatus
        summaryDescriptionLabel.text = model.summaryDescription
        windView.configure(with: model.wind)
        gustsView.configure(with: model.gusts)
        windDirectionView.configure(with: model.windDirection)
    }
}

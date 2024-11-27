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
    
    private let summaryContainerView = UIView()
    
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
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 6
        return stackView
    }()
    
    private let windView = WindParamersView()
    private let gustsView = WindParamersView()
    private let windDirectionView = WindParamersView()
    
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
        addSubview(summaryContainerView)
        addSubview(windStackView)
        
        titleStackView.addArrangedSubview(titleIcon)
        titleStackView.addArrangedSubview(titleLabel)
        
        summaryContainerView.addSubview(summaryStackView)
        summaryStackView.addArrangedSubview(summaryStatusLabel)
        summaryStackView.addArrangedSubview(summaryDescriptionLabel)
        
        windStackView.addArrangedSubview(windView)
        windStackView.addArrangedSubview(gustsView)
        windStackView.addArrangedSubview(windDirectionView)
    }
    
    private func setUpConstraints() {
        titleStackView.snp.makeConstraints {
            $0.top.leading.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 6, bottom: 0, right: 0))
            $0.width.equalToSuperview().multipliedBy(0.5)
        }
        
        titleIcon.snp.makeConstraints {
            $0.height.width.equalTo(17)
        }
        
        windStackView.snp.makeConstraints {
            $0.top.equalTo(titleStackView.snp.bottom).offset(6)
            $0.bottom.equalToSuperview()
            $0.leading.equalToSuperview().offset(6)
            $0.width.equalToSuperview().multipliedBy(0.5)
        }
        summaryContainerView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(6)
            $0.bottom.trailing.equalToSuperview()
            $0.leading.equalTo(windStackView.snp.trailing)
        }
        
        summaryStackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(8)
        }
    }
}

// MARK: - ConfigurableView

extension WindView: ConfigurableView {
    
    struct Model {
        let title: String
        let summaryStatus: String
        let summaryDescription: String
        let wind: WindParamersView.Model
        let gusts: WindParamersView.Model
        let windDirection: WindParamersView.Model
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

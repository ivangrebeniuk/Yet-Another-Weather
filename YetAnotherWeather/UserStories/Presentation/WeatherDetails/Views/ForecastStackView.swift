//
//  ForecastStackView.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 19.11.2024.
//

import Foundation
import UIKit

final class ForecastStackView: UIView {
    
    // UI
    private var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 6
        return stackView
    }()
    
    private var titleStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 6
        return stackView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: CGFloat(15), weight: .medium)
        label.textColor = .white
        return label
    }()
    
    private let containerView = UIView()
    
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
        addSubview(stackView)
        
        containerView.addSubview(titleStackView)
        titleStackView.addArrangedSubview(titleIcon)
        titleStackView.addArrangedSubview(titleLabel)
        
        stackView.addArrangedSubview(containerView)
    }
    
    private func setUpConstraints() {
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(
                UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 6)
            )
        }
        
        titleStackView.snp.makeConstraints {
            $0.height.equalToSuperview()
            $0.leading.equalToSuperview()
        }
        
        titleIcon.snp.makeConstraints {
            $0.height.width.equalTo(17)
        }
    }
}

// MARK: - ConfigurableVIew

extension ForecastStackView: ConfigurableView {
    
    struct Model {
        let titleLabel: String
        let daysForecasts: [SingleDayForecastView.Model]
    }
    
    func configure(with model: ForecastStackView.Model) {
        titleLabel.text = model.titleLabel
        
        _ = model.daysForecasts.map { model in
            let view = SingleDayForecastView()
            view.configure(with: model)
            stackView.addArrangedSubview(view)
        }
    }
}
    

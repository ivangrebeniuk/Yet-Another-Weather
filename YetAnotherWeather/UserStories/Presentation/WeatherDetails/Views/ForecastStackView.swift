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
        stackView.alpha = 0.6
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
        addSubview(titleStackView)
        addSubview(daysStackView)
        
        titleStackView.addArrangedSubview(titleIcon)
        titleStackView.addArrangedSubview(titleLabel)
    }
    
    private func setUpConstraints() {
        titleStackView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview().inset(
                UIEdgeInsets(top: 8, left: 6, bottom: 0, right: 6)
            )
        }
        
        titleIcon.snp.makeConstraints {
            $0.height.width.equalTo(17)
        }
        
        daysStackView.snp.makeConstraints {
            $0.top.equalTo(titleStackView.snp.bottom).offset(6)
            $0.leading.trailing.bottom.equalToSuperview().inset(
                UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 6)
            )
        }
    }
}

// MARK: - ConfigurableVIew

extension ForecastView: ConfigurableView {
    
    struct Model {
        let titleLabel: String
        let daysForecasts: [SingleDayForecastView.Model]
    }
    
    func configure(with model: ForecastView.Model) {
        titleLabel.text = model.titleLabel
        
        daysStackView.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }
        
        for model in model.daysForecasts {
            let view = SingleDayForecastView()
            view.configure(with: model)
            daysStackView.addArrangedSubview(view)
        }
    }
}
    

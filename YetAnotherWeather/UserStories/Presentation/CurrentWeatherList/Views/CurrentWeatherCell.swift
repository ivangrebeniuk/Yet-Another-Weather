//
//  CurrentWeatherCell.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 01.06.2024.
//

import SnapKit
import UIKit

private extension UIColor {
    static let daySkyBlue = UIColor(red: 0.53, green: 0.81, blue: 0.92, alpha: 1.00)
    static let nightSkyBlue = UIColor(red: 0.18, green: 0.27, blue: 0.51, alpha: 1.00)
}

final class CurrentWeatherCell: UITableViewCell {
    
    // UI
    private let containerView = UIView()
    
    private let cityLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: CGFloat(25), weight: .bold)
        label.textColor = .white
        label.textAlignment = .left
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: CGFloat(15), weight: .medium)
        label.textColor = .white
        label.textAlignment = .left
        return label
    }()
    
    private let conditionsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: CGFloat(16), weight: .medium)
        label.textAlignment = .left
        label.textColor = .white
        label.numberOfLines = 2
        return label
    }()
    
    private let temperatureLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: CGFloat(53), weight: .light)
        label.textColor = .white
        label.textAlignment = .right
        return label
    }()
    
    private let feelsLikeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: CGFloat(15), weight: .medium)
        label.textColor = .white
        label.textAlignment = .right
        return label
    }()
    
    // Private
    private var containerViewBackgroundColor: UIColor?
        
    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpUI()
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.layer.cornerRadius = 12
        layer.masksToBounds = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cityLabel.text = nil
        temperatureLabel.text = nil
        timeLabel.text = nil
        conditionsLabel.text = nil
        feelsLikeLabel.text = nil
        containerView.layer.cornerRadius = 0
        containerView.backgroundColor = .clear
    }
    
    // MARK: - Private
    
    private func setUpUI() {
        addSubview(containerView)
        addGestureToContainerView()
        containerView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.top.bottom.trailing.equalToSuperview()
        }
        
        let horizontalStackView = UIStackView()
        horizontalStackView.axis = .horizontal
        containerView.addSubview(horizontalStackView)
        horizontalStackView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        
        let rightSideContainer = UIView()
        let leftSideContainer = UIView()
        
        horizontalStackView.addArrangedSubview(leftSideContainer)
        horizontalStackView.addArrangedSubview(rightSideContainer)
        
        leftSideContainer.snp.makeConstraints {
            $0.width.equalToSuperview().multipliedBy(0.65)
        }
        rightSideContainer.snp.makeConstraints {
            $0.width.equalToSuperview().multipliedBy(0.35)
        }
        
        let cityAndTimeStackView = UIStackView()
        cityAndTimeStackView.axis = .vertical
        cityAndTimeStackView.alignment = .leading
        cityAndTimeStackView.spacing = 0
        
        cityAndTimeStackView.addArrangedSubview(cityLabel)
        cityAndTimeStackView.addArrangedSubview(timeLabel)
        
        leftSideContainer.addSubview(cityAndTimeStackView)
        cityAndTimeStackView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(10)
            $0.leading.trailing.equalToSuperview()
        }
        
        leftSideContainer.addSubview(conditionsLabel)
        conditionsLabel.snp.makeConstraints {
            $0.top.greaterThanOrEqualTo(cityAndTimeStackView.snp.bottom).inset(10)
            $0.bottom.equalToSuperview().inset(12)
            $0.leading.trailing.equalToSuperview()
        }
                
        rightSideContainer.addSubview(temperatureLabel)
        rightSideContainer.addSubview(feelsLikeLabel)
        
        temperatureLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(4)
            $0.leading.trailing.equalToSuperview()
        }
        feelsLikeLabel.snp.makeConstraints {
            $0.top.greaterThanOrEqualTo(temperatureLabel.snp.bottom).inset(19)
            $0.bottom.equalToSuperview().inset(12)
            $0.leading.trailing.equalToSuperview()
        }
    }
    
    private func addGestureToContainerView() {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleContainerViewTap))
            containerView.addGestureRecognizer(tapGesture)
        }
        
        @objc private func handleContainerViewTap() {}
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        UIView.animate(withDuration: 0.1) {
            if highlighted {
                self.containerView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
                self.containerView.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
            } else {
                self.containerView.transform = CGAffineTransform.identity
                self.containerView.backgroundColor = self.containerViewBackgroundColor
            }
        }
    }
}

// MARK: - ConfigurableView

extension CurrentWeatherCell: ConfigurableView {
    
    struct Model: Hashable, Equatable {
        let location: String
        let temperature: String
        let localTime: String
        let isDay: Bool
        let conditions: String
        let feelsLike: String
    }
    
    func configure(with model: Model) {
        cityLabel.text = model.location
        timeLabel.text = model.localTime
        temperatureLabel.text = model.temperature
        conditionsLabel.text = model.conditions
        feelsLikeLabel.text = model.feelsLike
        containerViewBackgroundColor = model.isDay ? UIColor.daySkyBlue : UIColor.nightSkyBlue
        containerView.backgroundColor = containerViewBackgroundColor
    }
}

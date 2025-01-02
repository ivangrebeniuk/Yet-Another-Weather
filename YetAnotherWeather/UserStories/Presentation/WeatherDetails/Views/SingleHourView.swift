//
//  SingleHourView.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 23.12.2024.
//

import Kingfisher
import SnapKit
import UIKit

final class SingleHourView: UIView {
    
    // UI
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let temperatureLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 12
        return stackView
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private
    
    private func setUpUI() {
        addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        stackView.addArrangedSubview(timeLabel)
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(temperatureLabel)
        
        imageView.snp.makeConstraints {
            $0.size.equalTo(32)
        }
    }
}

extension SingleHourView: ConfigurableView {
    
    struct Model {
        let temperature: String
        let time: String
        let imageURL: URL
    }
    
    func configure(with model: SingleHourView.Model) {
        timeLabel.text = model.time
        imageView.kf.setImage(with: model.imageURL)
        temperatureLabel.text = model.temperature
    }
}

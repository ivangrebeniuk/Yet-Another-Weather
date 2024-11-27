//
//  WindParamersView.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 23.11.2024.
//

import Foundation
import SnapKit
import UIKit

final class WindParamersView: UIView {

    // UI
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: CGFloat(18), weight: .regular)
        label.textColor = .white
        label.textAlignment = .left
        return label
    }()
    
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: CGFloat(18), weight: .regular)
        label.alpha = 0.6
        label.textColor = .white
        label.textAlignment = .right
        return label
    }()
    
    private let bottomBorder: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray5
        return view
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
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
        addSubview(stackView)
        addSubview(bottomBorder)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(valueLabel)
    }
    
    private func setUpConstraints() {
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        bottomBorder.snp.makeConstraints {
            $0.height.equalTo(0.5)
            $0.bottom.equalTo(stackView.snp.bottom).offset(6)
            $0.leading.trailing.equalToSuperview()
        }
    }
}

// MARK: - ConfigurableView

extension WindParamersView: ConfigurableView {
    
    struct Model {
        let title: String
        let value: String
    }
    
    func configure(with model: WindParamersView.Model) {
        titleLabel.text = model.title
        valueLabel.text = model.value
    }
}

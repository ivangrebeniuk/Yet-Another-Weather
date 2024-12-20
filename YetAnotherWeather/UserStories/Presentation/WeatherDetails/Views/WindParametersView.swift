//
//  WindParametersView.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 23.11.2024.
//

import Foundation
import SnapKit
import UIKit

final class WindParametersView: UIView {

    // UI
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: CGFloat(16), weight: .regular)
        label.textColor = .white
        label.textAlignment = .left
        return label
    }()
    
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: CGFloat(16), weight: .regular)
        label.alpha = 0.6
        label.textColor = .white
        label.textAlignment = .right
        return label
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
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
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(valueLabel)
    }
    
    private func setUpConstraints() {
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

// MARK: - ConfigurableView

extension WindParametersView: ConfigurableView {
    
    struct Model {
        let title: String
        let value: String
    }
    
    func configure(with model: WindParametersView.Model) {
        titleLabel.text = model.title
        valueLabel.text = model.value
    }
}

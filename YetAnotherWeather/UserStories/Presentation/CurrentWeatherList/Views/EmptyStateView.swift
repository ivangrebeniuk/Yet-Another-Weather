//
//  EmptyStateView.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 29.12.2024.
//

import Foundation
import SnapKit
import UIKit

private extension String {
    static let titleLabelText = "Welcome to the YetAnotherWeather"
    static let descriptionLabelText = "Please, feel free to search your favourite locations, add them to the list. And get accurate 💎 weather forecast!\n🌈"
}

final class EmptyStateView: UIView {
    
    // UI
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: CGFloat(24), weight: .bold)
        label.textAlignment = .center
        label.text = .titleLabelText
        label.textColor = .white
        return label
    }()
    
    private var descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: CGFloat(20), weight: .medium)
        label.textAlignment = .center
        label.text = .descriptionLabelText
        label.textColor = .white
        return label
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
        backgroundColor = .darkGray
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 8
        
        addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(12)
        }
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(descriptionLabel)
    }
}

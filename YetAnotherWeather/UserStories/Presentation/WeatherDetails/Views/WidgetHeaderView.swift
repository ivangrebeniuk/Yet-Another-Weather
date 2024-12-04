//
//  WidgetHeaderView.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 03.12.2024.
//

import Foundation
import SnapKit
import UIKit

final class WidgetHeaderView: UIView {
    
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
        imageView.tintColor = .white
        return imageView
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
        addSubview(titleStackView)
        titleStackView.addArrangedSubview(titleIcon)
        titleStackView.addArrangedSubview(titleLabel)
        
        titleStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        titleIcon.snp.makeConstraints {
            $0.size.equalTo(17)
        }
    }
}

// MARK: - ConfigurableView

extension WidgetHeaderView: ConfigurableView {
    
    struct Model {
        let imageTitle: String
        let headerTitleText: String
    }
    
    func configure(with model: Model) {
        titleLabel.text = model.headerTitleText
        titleIcon.image = UIImage.init(systemName: model.imageTitle)
    }
}

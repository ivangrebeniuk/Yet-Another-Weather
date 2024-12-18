//
//  SpacerCell.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 16.12.2024.
//

import Foundation
import SnapKit
import UIKit

final class SpacerCell: UITableViewCell {
    
    // UI
    private let containerView = UIView()
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private
    
    private func setUpUI() {
        addSubview(containerView)
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

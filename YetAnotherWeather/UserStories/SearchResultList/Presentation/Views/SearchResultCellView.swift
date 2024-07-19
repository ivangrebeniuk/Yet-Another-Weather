//
//  SearchResultCellView.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 19.07.2024.
//

import UIKit
import SnapKit

final class SearchResultCellView: UITableViewCell {
    
    // UI
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
    }
    
    // MARK: - Private
    
    private func setUpConstraints() {
        addSubview(containerView)
        containerView.addSubview(titleLabel)
        
        containerView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalToSuperview().offset(2)
            $0.bottom.equalToSuperview().offset(-2)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().offset(2)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }
    }
}

// MARK: ConfigurableView

extension SearchResultCellView: ConfigurableView {
    
    struct Model {
        let title: String
    }
    
    func configure(with model: Model) {
        titleLabel.text = model.title
    }
}

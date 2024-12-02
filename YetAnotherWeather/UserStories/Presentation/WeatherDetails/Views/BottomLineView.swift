//
//  BottomLineView.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 30.11.2024.
//

import Foundation
import SnapKit
import UIKit

final class BottomLineView: UIView {
    
    struct Configuration {
        let lineColor: UIColor
        let lineHeight: CGFloat
        let lineInsets: CGFloat
        
        static var `default`: Self = .init(
            lineColor: .systemGray5,
            lineHeight: 0.5,
            lineInsets: 6
        )
    }
    
    // UI
    private let lineView: UIView = {
        let view = UIView()
        view.alpha = 0.6
        return view
    }()
    
    // MARK: - Init
    
    init(configuration: BottomLineView.Configuration) {
        super.init(frame: .zero)
        setUpUI(configuration: configuration)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private
    
    private func setUpUI(configuration: BottomLineView.Configuration) {
        addSubview(lineView)
        
        lineView.backgroundColor = configuration.lineColor
        
        lineView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(configuration.lineInsets)
            $0.height.equalTo(configuration.lineHeight)
        }
    }
}

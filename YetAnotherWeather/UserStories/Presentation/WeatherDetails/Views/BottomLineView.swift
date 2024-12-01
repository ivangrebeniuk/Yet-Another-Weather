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
    
    // UI
    private let bottomLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray5
        view.alpha = 0.6
        return view
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpUI() {
        addSubview(bottomLineView)
        
        bottomLineView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(6)
            $0.height.equalTo(0.5)            
        }
    }
}

//
//  UIView+Wrapped.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 01.12.2024.
//

import Foundation
import SnapKit
import UIKit

extension UIView {
    
    func wrappedInBlurred() -> UIVisualEffectView {
        
        let blurEffectView = UIVisualEffectView(
            effect: UIBlurEffect(style: .systemThinMaterialDark)
        )
        
        blurEffectView.contentView.addSubview(self)
        blurEffectView.layer.masksToBounds = true

        self.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        return blurEffectView
    }
}

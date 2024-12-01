//
//  UIView+Wrapped.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 01.12.2024.
//

import Foundation
import SnapKit
import UIKit

public extension UIView {
    
    func blurred(cornerRadius: CGFloat) -> UIVisualEffectView {
        
        let blurEffectView = UIVisualEffectView(
            effect: UIBlurEffect(style: .dark)
        )
        
        blurEffectView.contentView.addSubview(self)
        blurEffectView.layer.masksToBounds = true
        blurEffectView.layer.cornerRadius = cornerRadius

        self.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        return blurEffectView
    }
}

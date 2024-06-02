//
//  ConfigurableView.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 01.06.2024.
//

protocol ConfigurableView {
    
    associatedtype ConfigurableViewModel
    
    func configure(with model: ConfigurableViewModel)
}

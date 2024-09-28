//
//  WeatherDetailsViewController.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 30.07.2024.
//

import Foundation
import UIKit
import SnapKit

protocol IWeatherDetailsView: AnyObject {
    
}

final class WeatherDetailsViewController: UIViewController {
    
    // Dependencies
    
    private let presenter: IWeatherDetailsPresenter
    
    // MARK: - Init
    
    init(presenter: IWeatherDetailsPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavigationBar()
        view.backgroundColor = .systemMint
        
    }
    
    // MARK: - Private
    
    private func setUpNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Cancel",
            style: .done,
            target: self,
            action: #selector(cancelButtonTapped)
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Add",
            style: .plain,
            target: self,
            action: #selector(addButtonTapped)
        )
    }
    
    @objc private func cancelButtonTapped() {
        presenter.didRequestToDismiss()
    }
    
    @objc private func addButtonTapped() {
        presenter.didTapAddButton()
    }
}

// MARK: - IWeatherDetailsView

extension WeatherDetailsViewController: IWeatherDetailsView {
    
}

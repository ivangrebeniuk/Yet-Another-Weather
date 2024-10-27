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
    
    func updateView(wit model: WeatherDetailsViewModel)
}

final class WeatherDetailsViewController: UIViewController {
    
    // Dependencies
    private let presenter: IWeatherDetailsPresenter
    
    // UI
    let currentWeatherView = CurrentWeatherView()
    
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
        presenter.viewDidLoad()
        setUpNavigationBar()
        view.backgroundColor = .systemGray6
        setUpUI()
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
    
    private func setUpUI() {
        view.addSubview(currentWeatherView)
        
        currentWeatherView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(78)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(200)
        }
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
    
    func updateView(wit model: WeatherDetailsViewModel) {
        currentWeatherView.configure(with: model.currentWeatherViewModel)
    }
}

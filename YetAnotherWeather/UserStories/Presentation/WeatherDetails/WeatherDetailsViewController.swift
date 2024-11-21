//
//  WeatherDetailsViewController.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 30.07.2024.
//

import Foundation
import UIKit
import SnapKit

private extension String {
    
    static let alertTitle = "Something went wrong"
    static let alertMessage = "Try again later"
    static let alertButtonText = "OK"
}

protocol IWeatherDetailsView: AnyObject {

    func updateView(with model: WeatherDetailsViewModel)
    
    func startLoader()
    
    func stopLoader()
    
    func showAlert(withModel model: SingleButtonAlertViewModel)
}

final class WeatherDetailsViewController: UIViewController {
    
    // Dependencies
    private let presenter: IWeatherDetailsPresenter
    
    // UI
    private let currentWeatherView = CurrentWeatherView()
    private let backgroundImageView = UIImageView()
    private let loader = UIActivityIndicatorView(style: .large)
    private let forecastView = ForecastStackView()
    private let forecastContainerView = UIView()
    private let forecastBlurEffectView = UIVisualEffectView(
        effect: UIBlurEffect(style: .dark)
    )
    
    // MARK: - Init
    
    init(
        presenter: IWeatherDetailsPresenter
    ) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
        setUpUI()
        setUpConstraints()
        view.backgroundColor = .systemBackground
    }
    
    // MARK: - Private
    
    private func setUpNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Cancel",
            style: .plain,
            target: self,
            action: #selector(cancelButtonTapped)
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Add",
            style: .done,
            target: self,
            action: #selector(addButtonTapped)
        )
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.isTranslucent = true
    }
    
    private func setUpUI() {
        view.addSubview(backgroundImageView)
        view.addSubview(loader)
        view.addSubview(currentWeatherView)
        view.addSubview(forecastContainerView)
        forecastContainerView.addSubview(forecastBlurEffectView)
        forecastContainerView.addSubview(forecastView)
        
        setUpNavigationBar()
        setUpBlurEffect()
        loader.color = .darkGray
        
        forecastContainerView.layer.cornerRadius = 12
        forecastContainerView.layer.borderWidth = 0.5
        forecastContainerView.layer.borderColor = UIColor.systemGray5.cgColor
    }
    
    private func configureBackgroundImage(withImage imageTitle: String) {
        let image = UIImage(named: imageTitle)
        backgroundImageView.image = image
        backgroundImageView.contentMode = .scaleAspectFill
    }
    
    private func setUpBlurEffect() {
        forecastBlurEffectView.frame = forecastContainerView.bounds
        forecastBlurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        forecastBlurEffectView.layer.cornerRadius = 12
        forecastBlurEffectView.layer.masksToBounds = true
    }
    
    private func setUpConstraints() {
        backgroundImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        currentWeatherView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(78)
            $0.leading.trailing.equalToSuperview()
        }
        
        loader.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        forecastView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        forecastContainerView.snp.makeConstraints {
            $0.top.equalTo(currentWeatherView.snp.bottom).offset(18)
            $0.leading.trailing.equalToSuperview().inset(18)
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
    
    func updateView(with model: WeatherDetailsViewModel) {
        currentWeatherView.configure(with: model.currentWeatherViewModel)
        configureBackgroundImage(withImage: model.backgroundImageTitle)
        forecastView.configure(with: model.forecastViewModel)
        view.layoutIfNeeded()
    }
    
    func startLoader() {
        loader.startAnimating()
        currentWeatherView.isHidden = true
        forecastView.isHidden = true
    }
    
    func stopLoader() {
        loader.stopAnimating()
        currentWeatherView.isHidden = false
        forecastView.isHidden = false
    }
    
    func showAlert(withModel model: SingleButtonAlertViewModel) {
        let alertController = UIAlertController.makeSingleButtonAlert(model: model)
        present(alertController, animated: true)
    }
}

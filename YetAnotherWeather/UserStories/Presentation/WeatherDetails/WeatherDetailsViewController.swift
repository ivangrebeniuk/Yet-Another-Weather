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
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let currentWeatherView = CurrentWeatherView()
    private let backgroundImageView = UIImageView()
    private let loader = UIActivityIndicatorView(style: .medium)
    
    private let widgetsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 18
        return stackView
    }()
    
    private let hourlyForecastView = HourlyForecastView()
    private lazy var blurredHourlyForecastView = hourlyForecastView.wrappedInBlurred()
    
    private let forecastView = ForecastView()
    private lazy var blurredForecastContainer = forecastView.wrappedInBlurred()
    
    private let windView = WindView()
    private lazy var blurredWindContainerView = windView.wrappedInBlurred()
    
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
    
    private func setUpUI() {
        
        view.addSubview(backgroundImageView)
        view.addSubview(scrollView)
        view.addSubview(loader)
        
        scrollView.addSubview(contentView)
        
        contentView.addSubview(currentWeatherView)
        contentView.addSubview(widgetsStackView)
        widgetsStackView.addArrangedSubview(blurredHourlyForecastView)
        widgetsStackView.addArrangedSubview(blurredForecastContainer)
        widgetsStackView.addArrangedSubview(blurredWindContainerView)
        
        setUpNavigationBar()
        loader.color = .darkGray
        blurredHourlyForecastView.layer.cornerRadius = 16
        blurredForecastContainer.layer.cornerRadius = 16
        blurredWindContainerView.layer.cornerRadius = 16
    }
    
    private func setUpConstraints() {
        backgroundImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
            
        contentView.snp.makeConstraints {
            $0.edges.equalTo(scrollView)
            $0.width.equalTo(scrollView)
        }
        
        currentWeatherView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(34)
            $0.leading.trailing.equalToSuperview()
        }
        
        loader.snp.makeConstraints {
            $0.center.equalToSuperview()
        }

        widgetsStackView.snp.makeConstraints {
            $0.top.equalTo(currentWeatherView.snp.bottom).offset(18)
            $0.leading.trailing.equalToSuperview().inset(12)
            $0.bottom.equalToSuperview().inset(40)
        }
    }
    
    private func configureBackgroundImage(withImage imageTitle: String) {
        let image = UIImage(named: imageTitle)
        backgroundImageView.image = image
        backgroundImageView.contentMode = .scaleAspectFill
    }
    
    private func setUpNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Cancel",
            style: .plain,
            target: self,
            action: #selector(cancelButtonTapped)
        )
        if !presenter.isAddedToFavourites {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: "Add",
                style: .done,
                target: self,
                action: #selector(addButtonTapped)
            )
        }
        
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.isTranslucent = true
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
        configureBackgroundImage(withImage: model.backgroundImageTitle)
        currentWeatherView.configure(with: model.currentWeatherViewModel)
        forecastView.configure(with: model.forecastViewModel)
        windView.configure(with: model.windViewModel)
        hourlyForecastView.configure(with: model.hourlyForecastModel)
    }
    
    func startLoader() {
        loader.startAnimating()
        currentWeatherView.isHidden = true
        blurredHourlyForecastView.isHidden = true
        blurredForecastContainer.isHidden = true
        blurredWindContainerView.isHidden = true
    }
    
    func stopLoader() {
        loader.stopAnimating()
        currentWeatherView.isHidden = false
        blurredHourlyForecastView.isHidden = false
        blurredForecastContainer.isHidden = false
        blurredWindContainerView.isHidden = false
    }
    
    func showAlert(withModel model: SingleButtonAlertViewModel) {
        let alertController = UIAlertController.makeSingleButtonAlert(model: model)
        present(alertController, animated: true)
    }
}

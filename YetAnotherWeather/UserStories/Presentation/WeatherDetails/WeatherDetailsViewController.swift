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
    
    private let forecastView = ForecastView()
    private let forecastContainerView = UIView()
    
    private let windView = WindView()
    private let windContainerView = UIView()
    
    private let blurredForecastContainer = UIView().blurred(cornerRadius: 12)
    private let blurredWindContainerView = UIView().blurred(cornerRadius: 12)
    
    private let garbageView1: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let garbageView2: UIView = {
        let view = UIView()
        view.backgroundColor = .green
        view.layer.cornerRadius = 12
        return view
    }()
    
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
        
        scrollView.addSubview(contentView)
        
        contentView.addSubview(loader)
        contentView.addSubview(currentWeatherView)
        contentView.addSubview(forecastContainerView)
        contentView.addSubview(windContainerView)
        
        forecastContainerView.addSubview(blurredForecastContainer)
        forecastContainerView.addSubview(forecastView)
        windContainerView.addSubview(blurredWindContainerView)
        windContainerView.addSubview(windView)
        
        setUpNavigationBar()
        loader.color = .darkGray
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
            $0.bottom.equalTo(windContainerView.snp.bottom).offset(18)
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
        
        windView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        forecastContainerView.snp.makeConstraints {
            $0.top.equalTo(currentWeatherView.snp.bottom).offset(18)
            $0.leading.trailing.equalToSuperview().inset(18)
        }
        
        windContainerView.snp.makeConstraints {
            $0.top.equalTo(forecastContainerView.snp.bottom).offset(18)
            $0.leading.trailing.equalToSuperview().inset(18)
        }
        
        blurredForecastContainer.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        blurredWindContainerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
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
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Add",
            style: .done,
            target: self,
            action: #selector(addButtonTapped)
        )
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
    }
    
    func startLoader() {
        loader.startAnimating()
        currentWeatherView.isHidden = true
        forecastContainerView.isHidden = true
        windContainerView.isHidden = true
    }
    
    func stopLoader() {
        loader.stopAnimating()
        currentWeatherView.isHidden = false
        forecastContainerView.isHidden = false
        windContainerView.isHidden = false
    }
    
    func showAlert(withModel model: SingleButtonAlertViewModel) {
        let alertController = UIAlertController.makeSingleButtonAlert(model: model)
        present(alertController, animated: true)
    }
}

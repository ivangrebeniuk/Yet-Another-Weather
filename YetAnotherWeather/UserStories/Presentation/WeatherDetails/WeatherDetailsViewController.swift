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
    
    /// Update UI
    ///  paramters: - `model`
    func updateView(wit model: WeatherDetailsViewModel)
    
    /// Show activity indicator
    func startLoader()
    
    /// Hide activity indicator
    func stopLoader()
    
    /// Show error alert message
    func showAlert()
}

final class WeatherDetailsViewController: UIViewController {
    
    // Dependencies
    private let presenter: IWeatherDetailsPresenter
    
    // UI
    private let currentWeatherView = CurrentWeatherView()
    private let backgroundImageView = UIImageView()
    private let loader = UIActivityIndicatorView(style: .large)
    
    private lazy var alertController = configureAlertMessage(
        with: .alertTitle,
        message: .alertMessage,
        firstButtonText: .alertButtonText,
        firstButtonStyle: .cancel,
        actionHandler: { [weak self] in
            self?.presenter.didRequestToDismiss()
        }
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
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    private func setUpUI() {
        view.addSubview(backgroundImageView)
        view.addSubview(loader)
        view.addSubview(currentWeatherView)
        
        setUpNavigationBar()
    }
    
    private func setUpBackground(withImage imageTitle: String) {
        let image = UIImage(named: imageTitle)
        backgroundImageView.image = image
        backgroundImageView.contentMode = .scaleAspectFill
    }
    
    private func setUpConstraints() {
        backgroundImageView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
        
        currentWeatherView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(78)
            $0.leading.trailing.equalToSuperview()
        }
        
        loader.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
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
        setUpBackground(withImage: model.backgroundImageTitle)
    }
    
    func startLoader() {
        loader.color = .white
        loader.startAnimating()
        currentWeatherView.isHidden = true
    }
    
    func stopLoader() {
        loader.stopAnimating()
        currentWeatherView.isHidden = false
    }
    
    func showAlert() {
        showAlert(alertController)
    }
}

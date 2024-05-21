//
//  WeatherListViewController.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 13.05.2024.
//

import Foundation
import SnapKit

protocol IWeatherListView: AnyObject {
    
}

class WeatherListViewController: UIViewController {
    
    var presenter: IWeatherListPresenter
    
    // MARK: - Init
    
    init(presenter: IWeatherListPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecicle
    
    override func viewDidLoad() {
        view.backgroundColor = .systemBackground
        presenter.viewDidLoad()
        navigationItem.title = "Weather"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    // MARK: - Private
}

    // MARK: - IWeatherListView

extension WeatherListViewController: IWeatherListView {
    
}

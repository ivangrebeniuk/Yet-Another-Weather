//
//  CurrentWeatherListViewController.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 13.05.2024.
//

import Foundation
import SnapKit

private extension String {
    static let weatherHeaderText = "Weather"
    static let searchFielPlaceholderText = "Type city to search"
}

protocol ICurrentWeatherListView: AnyObject {
    
    func hideSearchResults()
}

class CurrentWeatherListViewController: UIViewController {
    
    // Dependencies
    private let resultsViewController: UIViewController
    private let presenter: ICurrentWeatherListPresenter
    private lazy var searchController = UISearchController(searchResultsController: resultsViewController)

    
    // MARK: - UI
    
    private lazy var button: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Кнопка", for: .normal)
        
        button.layer.cornerRadius = 18
        button.backgroundColor = .systemBlue
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        
        button.addAction(.init(handler: { [weak self] _ in self?.buttonTapped() }), for: .touchUpInside)
        return button
    }()
    
    
    // MARK: - Init
    
    init(
        resultsViewController: UIViewController,
        presenter: ICurrentWeatherListPresenter
    ) {
        self.resultsViewController = resultsViewController
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecicle
    
    override func viewDidLoad() {
        view.backgroundColor = .systemBackground
        setUpNavigationBar()
        setUpConstraints()
    }
    
    // MARK: - Private
    
    private func setUpNavigationBar() {
        navigationItem.title = .weatherHeaderText
        navigationController?.navigationBar.prefersLargeTitles = true
        
        searchController.searchResultsUpdater = resultsViewController as? UISearchResultsUpdating
        searchController.obscuresBackgroundDuringPresentation = false
        
        searchController.searchBar.placeholder = .searchFielPlaceholderText
        
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    private func setUpConstraints() {
        view.addSubview(button)
        
        button.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(200)
        }
    }
    
    private func buttonTapped() {
        print("YO!")
        presenter.getOrderedWeatherItems()
    }
}

// MARK: - IWeatherListView

extension CurrentWeatherListViewController: ICurrentWeatherListView {
    
    func hideSearchResults() {
        searchController.isActive = false
    }
}

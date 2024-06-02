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
    static let searchFielPlaceholderText = "Type city or country to search"
}

protocol ICurrentWeatherListView: AnyObject {
    
}

class CurrentWeatherListViewController: UIViewController {
    
    var presenter: ICurrentWeatherListPresenter
    
    // MARK: - UI
    
    
    
    // MARK: - Init
    
    init(presenter: ICurrentWeatherListPresenter) {
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
        presenter.viewDidLoad()
        
    }
    
    // MARK: - Private
    
    private func setUpNavigationBar() {
        navigationItem.title = .weatherHeaderText
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = .searchFielPlaceholderText
        navigationItem.searchController = searchController
    }
}

// MARK: - IWeatherListView

extension CurrentWeatherListViewController: ICurrentWeatherListView {
    
}

// MARK: - UISearchResultsUpdating
extension CurrentWeatherListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        
    }
}

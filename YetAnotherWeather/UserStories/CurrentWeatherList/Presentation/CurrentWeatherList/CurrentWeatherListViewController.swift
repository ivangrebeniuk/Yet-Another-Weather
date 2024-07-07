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
    
    // Dependencies
    var presenter: ICurrentWeatherListPresenter
    
    // MARK: - UI
    
    private lazy var button: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Кнопка", for: .normal)
        
        button.layer.cornerRadius = 18
        button.backgroundColor = .systemBlue
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        
        button.addTarget(self, action:#selector(buttonTapped), for: .touchUpInside)
        return button
    }()
    
    
    // MARK: - Init
    
    init(
        presenter: ICurrentWeatherListPresenter
    ) {
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
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = true
        searchController.searchBar.placeholder = .searchFielPlaceholderText
        navigationItem.searchController = searchController
    }
    
    private func setUpConstraints() {
        view.addSubview(button)
        
        button.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(200)
        }
    }
    
    @IBAction private func buttonTapped(_ sender: UIButton) {
        // presenter.getOrderedWeatherItems()
        presenter.getOrderedWeatherItems()
    }
}

// MARK: - IWeatherListView

extension CurrentWeatherListViewController: ICurrentWeatherListView {
    
}

// MARK: - UISearchResultsUpdating
extension CurrentWeatherListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text, text.count > 2 else { return }
    }
}

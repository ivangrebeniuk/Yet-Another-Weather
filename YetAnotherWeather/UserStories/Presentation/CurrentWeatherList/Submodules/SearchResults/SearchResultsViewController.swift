//
//  SearchResultsViewController.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 19.07.2024.
//

import UIKit
import SnapKit

protocol ISearchResultsView: AnyObject {
    
    var searchQuerry: String? { get }
    func updateTableView()
}

final class SearchResultsViewController: UIViewController {
    
    // Dependencies
    private let presenter: ISearchResultsPresenter
    
    // Models
    private let cellIdentifier = SearchResultCellView.description()
    private(set) var searchQuerry: String?

    // UI
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(SearchResultCellView.self, forCellReuseIdentifier: cellIdentifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .systemBackground
        return tableView
    }()
    
    // MARK: - Init
    
    init(
        presenter: ISearchResultsPresenter
    ) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpConstraints()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // MARK: - Private
    
    private func setUpConstraints() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.left.right.bottom.equalToSuperview()
        }
    }
}

// MARK: - UITableViewDataSource

extension SearchResultsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.searchResultViewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: cellIdentifier,
            for: indexPath
        ) as? SearchResultCellView else {
            return UITableViewCell()
        }
        
        let model = presenter.searchResultViewModels[indexPath.row]
        cell.configure(with: model)
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension SearchResultsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        presenter.didTapCell(atIndex: indexPath)
    }
}

// MARK: - ISearchResultListView

extension SearchResultsViewController: ISearchResultsView {
    
    func updateTableView() {
        tableView.reloadData()
    }
}

// MARK: - UISearchResultsUpdating

extension SearchResultsViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        searchQuerry = searchController.searchBar.text
        presenter.viewDidLoad()
    }
}

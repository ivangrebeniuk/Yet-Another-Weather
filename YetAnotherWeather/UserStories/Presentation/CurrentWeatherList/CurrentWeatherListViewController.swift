//
//  CurrentWeatherListViewController.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 13.05.2024.
//

import Foundation
import SnapKit
import UIKit

private extension String {
    
    static let weatherHeaderText = "Weather"
    static let searchFielPlaceholderText = "Type location to search"
    static let currentWeatherCellIdentifier = "CurrentWeatherCellIdentifier"
    static let spacerCellIdentifier = "SpacerCellIdentifier"
}

private extension CGFloat {
    
    static let weatherCellHeight: CGFloat = 128
    static let spacerCellHeight: CGFloat = 10
}

protocol ICurrentWeatherListView: AnyObject {
    
    func update(with items: [CurrentWeatherCell.Model])
    func hideSearchResults()
    func endRefreshing()
    func showAlert(with model: SingleButtonAlertViewModel)
}

final class CurrentWeatherListViewController: UIViewController {
    
    private enum Section {
        case main
    }
    private typealias Item = CurrentWeatherCellType
    private typealias DataSource = UITableViewDiffableDataSource<Section, Item>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    
    // Dependencies
    private let resultsViewController: UIViewController
    private let presenter: ICurrentWeatherListPresenter
    private lazy var searchController = UISearchController(searchResultsController: resultsViewController)

    
    // UI
    private lazy var tableView = UITableView()
    private lazy var dataSource = makeDataSourcre()
    private lazy var refreshControl = UIRefreshControl()
    
    // Models
    private var itemsArray = [CurrentWeatherCellType]()
    
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
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setUpUI()
        presenter.viewDidLoad()
    }
    
    // MARK: - Private
    
    private func setUpUI() {
        setUpNavigationBar()
        setUpTableView()
        setUpRefreshControl()
    }
    
    private func setUpNavigationBar() {
        navigationItem.title = .weatherHeaderText
        navigationController?.navigationBar.prefersLargeTitles = true
        
        searchController.searchResultsUpdater = resultsViewController as? UISearchResultsUpdating
        searchController.searchBar.placeholder = .searchFielPlaceholderText
        
        navigationItem.searchController = searchController
    }
    
    private func setUpTableView() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 15, left: 0, bottom: 40, right: 20))
        }
        tableView.delegate = self
        tableView.register(CurrentWeatherCell.self, forCellReuseIdentifier: .currentWeatherCellIdentifier)
        tableView.register(SpacerCell.self, forCellReuseIdentifier: .spacerCellIdentifier)
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
    }
    
    private func calculateIndex(from indexPath: IndexPath) {
        guard indexPath.row % 2 == 0 else { return }
    }
    
    private func makeDataSourcre() -> DataSource {
        DataSource(tableView: tableView) { tableView, indexPath, item in
            switch item {
            case .weather(let model):
                guard let weatherCell = tableView.dequeueReusableCell(
                    withIdentifier: .currentWeatherCellIdentifier,
                    for: indexPath
                ) as? CurrentWeatherCell else { return UITableViewCell() }
                weatherCell.configure(with: model)
                weatherCell.selectionStyle = .none
                return weatherCell
            case .spacer:
                guard let spacerCell = tableView.dequeueReusableCell(
                    withIdentifier: .spacerCellIdentifier,
                    for: indexPath
                ) as? SpacerCell else { return UITableViewCell() }
                spacerCell.selectionStyle = .none
                return spacerCell
            }
        }
    }
    
    private func setUpRefreshControl() {
        tableView.refreshControl = refreshControl
        tableView.refreshControl?.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
    }
    
    @objc private func handleRefreshControl() {
        presenter.didPullToRefresh()
    }
}

// MARK: - UITableViewDelegate

extension CurrentWeatherListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        indexPath.row % 2 == 0 ? .weatherCellHeight : .spacerCellHeight
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard indexPath.row % 2 == 0 else { return nil }
        let deleteAction = UIContextualAction(style: .destructive, title: "") { [weak self] (_, _, completionHandler) in
            self?.presenter.deleteLocation(atIndex: indexPath.row / 2)
            completionHandler(true)
        }
        
        deleteAction.image = UIImage.init(systemName: "trash")
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row % 2 == 0 else { return }
        
        tableView.deselectRow(at: indexPath, animated: true)
        presenter.didSelectRowAt(atIndex: indexPath.row / 2)
    }
}

// MARK: - IWeatherListView

extension CurrentWeatherListViewController: ICurrentWeatherListView {
    
    func hideSearchResults() {
        searchController.isActive = false
    }
    
    func update(with items: [CurrentWeatherCell.Model]) {
        
        itemsArray.removeAll()
                
        for (index, item) in items.enumerated() {
            itemsArray.append(.weather(item))
            if index < items.count - 1 {
                itemsArray.append(.spacer(UUID()))
            }
        }
        
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(itemsArray, toSection: .main)
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    func endRefreshing() {
        refreshControl.endRefreshing()
    }
    
    func showAlert(with model: SingleButtonAlertViewModel) {
        let alertController = UIAlertController.makeSingleButtonAlert(model: model)
        present(alertController, animated: true)
    }
}

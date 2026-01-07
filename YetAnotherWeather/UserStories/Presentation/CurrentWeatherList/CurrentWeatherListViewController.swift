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
    static let searchFielPlaceholderText = "Search for a city or airport"
    static let currentLocationCellIdentifier = "CurrentLocationCellIdentifier"
    static let currentWeatherCellIdentifier = "CurrentWeatherCellIdentifier"
    static let spacerCellIdentifier = "SpacerCellIdentifier"
}

private extension CGFloat {
    
    static let weatherCellHeight: CGFloat = 128
    static let spacerCellHeight: CGFloat = 10
}

private extension UIColor {
    
    static let backgroundColor = UIColor.systemBackground
}

protocol ICurrentWeatherListView: AnyObject {
        
    func updateCurrentLocationSection(with items: [CurrentWeatherCell.Model])
    
    func updateMainSection(with items: [CurrentWeatherCell.Model])
    
    func hideSearchResults()
    
    func endRefreshing()
    
    func showAlert(with model: SingleButtonAlertViewModel)
    
    func startActivityIndicator()
    
    func stopActivityIndicator()
}

final class CurrentWeatherListViewController: UIViewController {
    
    enum Section {
        case currentLocation
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
    private lazy var activityIndicator = UIActivityIndicatorView(style: .medium)
    private lazy var tableView = UITableView()
    private lazy var dataSource = makeDataSourcre()
    private lazy var refreshControl = UIRefreshControl()
    private lazy var emptyStateView: UIView = {
        let containerView = UIView()
        containerView.backgroundColor = .clear
        
        let emptyStateView = EmptyStateView()
        emptyStateView.layer.cornerRadius = 16
        
        containerView.addSubview(emptyStateView)
        
        emptyStateView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.lessThanOrEqualToSuperview()
        }
        
        return containerView
    }()
    
    // Models
    private var currentLocationItemArray = [CurrentWeatherCellType]()
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
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setUpUI()
        presenter.viewDidLoad()
    }
    
    // MARK: - Private
    
    private func setUpUI() {
        view.backgroundColor = .backgroundColor
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 15, left: 0, bottom: 40, right: 20))
        }
        
        view.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
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
        tableView.backgroundColor = .backgroundColor
        tableView.delegate = self
        tableView.register(CurrentWeatherCell.self, forCellReuseIdentifier: .currentWeatherCellIdentifier)
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
                weatherCell.backgroundColor = .backgroundColor
                return weatherCell
            case .spacer:
                let spacerCell = UITableViewCell()
                spacerCell.selectionStyle = .none
                spacerCell.backgroundColor = .backgroundColor
                return spacerCell
            }
        }
    }
    
    private func setUpRefreshControl() {
        refreshControl.addTarget(
            self, action: #selector(handleRefreshControl),
            for: .valueChanged
        )
    }
    
    @objc private func handleRefreshControl() {
        presenter.didPullToRefresh()
    }
    
    private func updateEmptyState() {
        tableView.backgroundView = presenter.shouldShowEmptyState ? emptyStateView : nil
    }
    
    private func updateRefreshControl() {
        tableView.refreshControl = presenter.shouldShowEmptyState ? nil : refreshControl
    }
    
    private func updateMultipleSections() {
        var snapshot = dataSource.snapshot()
        snapshot.deleteSections(snapshot.sectionIdentifiers)
        snapshot.appendSections([.currentLocation, .main])
        
        snapshot.appendItems(currentLocationItemArray, toSection: .currentLocation)
        snapshot.appendItems(itemsArray, toSection: .main)
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

// MARK: - UITableViewDelegate

extension CurrentWeatherListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        indexPath.row % 2 == 0 ? .weatherCellHeight : .spacerCellHeight
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let section = dataSource.snapshot().sectionIdentifiers[indexPath.section]
        guard section != .currentLocation else {
            return nil
        }
            
        guard indexPath.row % 2 == 0 else { return nil }
        let deleteAction = UIContextualAction(style: .destructive, title: "") { [weak self] (_, _, completionHandler) in
            Task { @MainActor in
                await self?.presenter.deleteItem(atIndex: indexPath.row / 2)
                completionHandler(true)
            }
        }
        
        deleteAction.image = UIImage.init(systemName: "trash")
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row % 2 == 0 else { return }
        let section = dataSource.snapshot().sectionIdentifiers[indexPath.section]

        tableView.deselectRow(at: indexPath, animated: true)
        presenter.didSelectRowAt(atIndex: indexPath.row / 2, section: section)
    }
}

// MARK: - IWeatherListView

extension CurrentWeatherListViewController: ICurrentWeatherListView {
    
    func hideSearchResults() {
        searchController.isActive = false
    }
    
    func updateMainSection(with items: [CurrentWeatherCell.Model]) {
        itemsArray.removeAll()
                
        for (index, item) in items.enumerated() {
            itemsArray.append(.weather(item))
            if index < items.count - 1 {
                itemsArray.append(.spacer(UUID()))
            }
        }

        var snapshot = dataSource.snapshot()
        
        if !snapshot.sectionIdentifiers.contains(.main) {
            snapshot.appendSections([.main])
            
        }
        let favouriteLocationItems = snapshot.itemIdentifiers(inSection: .main)
        snapshot.deleteItems(favouriteLocationItems)
        
        snapshot.appendItems(itemsArray, toSection: .main)
        
        dataSource.apply(snapshot, animatingDifferences: true)
        updateRefreshControl()
        updateEmptyState()
    }
    
    func updateCurrentLocationSection(with items: [CurrentWeatherCell.Model]) {
        currentLocationItemArray.removeAll()
                
        for item in items {
            currentLocationItemArray.append(.weather(item))
            currentLocationItemArray.append(.spacer(UUID()))
        }
        
        var snapshot = dataSource.snapshot()
        
        if !snapshot.sectionIdentifiers.contains(.currentLocation) {
            snapshot.appendSections([.currentLocation])
        }
        
        let currentLocationItems = snapshot.itemIdentifiers(inSection: .currentLocation)
        snapshot.deleteItems(currentLocationItems)
        
        snapshot.appendItems(currentLocationItemArray, toSection: .currentLocation)
        
        dataSource.apply(snapshot, animatingDifferences: true)
        updateRefreshControl()
        updateEmptyState()
    }

    func endRefreshing() {
        refreshControl.endRefreshing()
    }
    
    func showAlert(with model: SingleButtonAlertViewModel) {
        let alertController = UIAlertController.makeSingleButtonAlert(model: model)
        present(alertController, animated: true)
    }
    
    func startActivityIndicator() {
        activityIndicator.startAnimating()
        tableView.isHidden = true
    }
    
    func stopActivityIndicator() {
        activityIndicator.stopAnimating()
        tableView.isHidden = false
    }
}

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
    static let searchFielPlaceholderText = "Type location to search"
    static let cellIdentifier = "CurrentWeatherCellIdentifier"
}

protocol ICurrentWeatherListView: AnyObject {
    
    func update(with items: [CurrentWeatherCell.Model])
    func hideSearchResults()
}

final class CurrentWeatherListViewController: UIViewController {
    
    private enum Section {
        case main
    }
    private typealias Item = CurrentWeatherCell.Model
    private typealias DataSource = UITableViewDiffableDataSource<Section, Item>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    
    // Dependencies
    private let resultsViewController: UIViewController
    private let presenter: ICurrentWeatherListPresenter
    private lazy var searchController = UISearchController(searchResultsController: resultsViewController)

    
    // UI
    private lazy var tableView = UITableView()
    private lazy var dataSource = makeDataSourcre()
    
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
        tableView.delegate = self
        tableView.register(CurrentWeatherCell.self, forCellReuseIdentifier: .cellIdentifier)
        setUpUI()
        presenter.viewDidLoad()
    }
    
    // MARK: - Private
    
    private func setUpUI() {
        setUpNavigationBar()
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 15, left: 20, bottom: 40, right: 20))
        }
    }
    
    private func setUpNavigationBar() {
        navigationItem.title = .weatherHeaderText
        navigationController?.navigationBar.prefersLargeTitles = true
        
        searchController.searchResultsUpdater = resultsViewController as? UISearchResultsUpdating
        searchController.searchBar.placeholder = .searchFielPlaceholderText
        
        navigationItem.searchController = searchController
    }
    
    private func makeDataSourcre() -> DataSource {
        DataSource(tableView: tableView) { tableView, indexPath, item in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: .cellIdentifier, for: indexPath) as? CurrentWeatherCell else {
                return UITableViewCell()
            }            
            cell.configure(with: item)
            cell.layer.cornerRadius = 12
            cell.layer.masksToBounds = true
            return cell
        }
    }
}

// MARK: - UITableViewDelegate

extension CurrentWeatherListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 128
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "") { [weak self] (_, _, completionHandler) in
            self?.presenter.deleteLocation(atIndex: indexPath.row)
            completionHandler(true)
        }
        
        deleteAction.image = UIImage.init(systemName: "trash")
        deleteAction.backgroundColor = .red
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        presenter.didSelectRowAt(indexPath: indexPath)
    }
}

// MARK: - IWeatherListView

extension CurrentWeatherListViewController: ICurrentWeatherListView {
    
    func hideSearchResults() {
        searchController.isActive = false
    }
    
    func update(with items: [CurrentWeatherCell.Model]) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

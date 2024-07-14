//
//  SearchResultsViewController.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 07.07.2024.
//

import UIKit
import SnapKit

protocol ISearchResultsView: AnyObject {
    
}

final class SearchResultsViewController: UIViewController {
    
    // Dependencies
    private let presenter: ISearchResultsPresenter

    // UI
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(SearchResultCellView.self, forCellReuseIdentifier: cellIdentifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .systemBackground
        return tableView
    }()
    
    
    // Model
    private var results = [SearchResult]()
    private let cellIdentifier = SearchResultCellView.description()
    
    enum Section {
        case main
    }
    
    // MARK: - Init
    
    init(presenter: ISearchResultsPresenter) {
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
    
    func updateResults(_ results: [SearchResult]) {
        self.results = results
        tableView.reloadData()
    }
    
    // MARK: - Private
    
    private func setUpConstraints() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.left.right.bottom.equalToSuperview()
        }
    }
    
    private func prepareModels() -> [SearchResultCellView.Model] {
        return results.map { result in
            let text = "\(result.name), \(result.country)"
            return SearchResultCellView.Model(title: text)
        }
    }
}

extension SearchResultsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: cellIdentifier,
            for: indexPath
        ) as? SearchResultCellView else {
            return UITableViewCell()
        }
        
        let models = prepareModels()
        cell.configure(with: models[indexPath.row])
        return cell
    }
}

extension SearchResultsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        print("Тапнули на ячейку. Город \(results[indexPath.row].name)")
    }
}

// MARK: - ISearchResultListView

extension SearchResultsViewController: ISearchResultsView {

}

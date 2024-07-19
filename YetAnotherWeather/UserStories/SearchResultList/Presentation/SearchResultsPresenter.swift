//
//  SearchResultsPresenter.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 19.07.2024.
//

import Foundation

protocol ISearchResultsPresenter: AnyObject {
    
    var searchResultViewModels: [SearchResultCellView.Model] { get }
    
//    func updateSearchResults(for searchQuerry: String?)
    
    func viewDidLoad()
}

final class SearchResultsPresenter {
    
    // Dependencies
    // private let coordinator: ICoordinator
    private let searchLocationsService: ISearchLocationsService
    
    weak var view: ISearchResultsView?
    
    // Models
    
    // ISearchResultsPresenter
    private(set) var searchResultViewModels = [SearchResultCellView.Model]()
    
    // MARK: - Init
    
    init(
        // coordinator: ICoordinator,
        searchLocationsService: ISearchLocationsService
    ) {
        // self.coordinator = coordinator
        self.searchLocationsService = searchLocationsService
    }
    
    // MARK: - Private
    
    private func searchLocations(text: String) {
        searchLocationsService.getSearchResults(for: text) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let results):
                DispatchQueue.main.async {
                    self.searchResultViewModels = self.makeViewModels(from: results)
                }
            case .failure(let error):
                print(error.localizedDescription)
                self.searchResultViewModels = []
            }
        }
    }
    
    private func makeViewModels(from models: [SearchResult]) -> [SearchResultCellView.Model] {
        return models.map { result in
            let text = "\(result.name), \(result.country)"
            return SearchResultCellView.Model(title: text)
        }
    }
    
    private func updateSearchResults(for searchQuerry: String?) {
        guard let searchQuerry = searchQuerry, searchQuerry.count > 2 else {
            searchResultViewModels = []
//            view?.updateTableView()
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.searchLocations(text: searchQuerry)
//            self?.view?.updateTableView()
        }
    }
}

// MARK: - ICurrentWeatherListPresenter

extension SearchResultsPresenter: ISearchResultsPresenter {
    
    
    func viewDidLoad() {
        updateSearchResults(for: view?.searchQuerry)
        view?.updateTableView()
    }
}

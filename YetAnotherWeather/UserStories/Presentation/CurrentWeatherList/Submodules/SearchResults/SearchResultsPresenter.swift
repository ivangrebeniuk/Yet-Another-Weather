//
//  SearchResultsPresenter.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 19.07.2024.
//

import Foundation

protocol SearchResultsOutput: AnyObject {
    
    func didSelectLocation(_ location: String)
}

protocol ISearchResultsPresenter: AnyObject {
    
    var searchResultViewModels: [SearchResultCellView.Model] { get }
        
    func viewDidLoad()
    
    func didTapCell(atIndex index: IndexPath)
}

final class SearchResultsPresenter {
    
    // Dependencies
    private let searchLocationsService: ISearchLocationsService
    private weak var output: SearchResultsOutput?
    weak var view: ISearchResultsView?
        
    // ISearchResultsPresenter
    private(set) var searchResultViewModels = [SearchResultCellView.Model]()
    
    // Models
    private var searchResults = [SearchResultModel]()
    
    // MARK: - Init
    
    init(
        searchLocationsService: ISearchLocationsService,
        output: SearchResultsOutput?
    ) {
        self.searchLocationsService = searchLocationsService
        self.output = output
    }
    
    // MARK: - Private
    
    private func searchLocations(text: String) {
        searchLocationsService.getSearchResults(for: text) { result in
            switch result {
            case .success(let results):
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    self.searchResults = results
                    self.searchResultViewModels = self.makeViewModels(from: results)
                    self.view?.updateTableView()
                }
            case .failure(let error):
                print(error.localizedDescription)
                self.searchResultViewModels = []
            }
        }
    }
    
    private func makeViewModels(from models: [SearchResultModel]) -> [SearchResultCellView.Model] {
        return models.map { result in
            let text = "\(result.name), \(result.country)"
            return SearchResultCellView.Model(title: text)
        }
    }
    
    private func updateSearchResults(for searchQuerry: String?) {
        guard
            let searchQuerry = searchQuerry,
            searchQuerry.count > 2
        else {
            searchResultViewModels = []
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.searchLocations(text: searchQuerry)
        }
    }
}

// MARK: - ICurrentWeatherListPresenter

extension SearchResultsPresenter: ISearchResultsPresenter {
    
    func viewDidLoad() {
        updateSearchResults(for: view?.searchQuerry)
    }
    
    func didTapCell(atIndex index: IndexPath) {
        let locationId = String(searchResults[index.row].id)
        output?.didSelectLocation(locationId)
    }
}

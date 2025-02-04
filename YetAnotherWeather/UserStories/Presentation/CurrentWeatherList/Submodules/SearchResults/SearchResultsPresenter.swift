//
//  SearchResultsPresenter.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 19.07.2024.
//

import Foundation

protocol SearchResultsOutput: AnyObject {
    
    func didSelectLocation(_ location: Location)
}

protocol ISearchResultsPresenter: AnyObject {
    
    var searchResultViewModels: [SearchResultCellView.Model] { get }
        
    func viewDidLoad()
    
    func didTapCell(atIndex index: IndexPath)
}

final class SearchResultsPresenter {
    
    // Dependencies
    private let searchLocationsService: ISearchLocationsService
    private let feedbackGeneratorService: IFeedbackGeneratorService
    private weak var output: SearchResultsOutput?
    weak var view: ISearchResultsView?
        
    // ISearchResultsPresenter
    private(set) var searchResultViewModels = [SearchResultCellView.Model]()
    
    // Models
    private var searchResults = [SearchResultModel]()
    
    // MARK: - Init
    
    init(
        searchLocationsService: ISearchLocationsService,
        feedbackGeneratorService: IFeedbackGeneratorService,
        output: SearchResultsOutput?
    ) {
        self.searchLocationsService = searchLocationsService
        self.feedbackGeneratorService = feedbackGeneratorService
        self.output = output
    }
    
    // MARK: - Private
    
    private func searchLocations(text: String) {
        searchLocationsService.getSearchResults(for: text) { result in
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                switch result {
                case .success(let results):
                    searchResults = results
                    searchResultViewModels = makeViewModels(from: results)
                case .failure(let error):
                    feedbackGeneratorService.generateFeedback(ofType: .notification(.error))
                    print(error.localizedDescription)
                    searchResultViewModels = []
                }
                view?.updateTableView()
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
            searchResults = []
            view?.updateTableView()
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
        feedbackGeneratorService.generateFeedback(ofType: .impact(.medium))
        guard index.row < searchResults.count else {
            print("!!! Index out of range")
            return
            }
        let locationId = String(searchResults[index.row].id)
        let locationName = String(searchResults[index.row].name)
        let location = Location(id: locationId, name: locationName)
        output?.didSelectLocation(location)
    }
}

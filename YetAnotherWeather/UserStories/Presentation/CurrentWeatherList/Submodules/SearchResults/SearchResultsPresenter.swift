//
//  SearchResultsPresenter.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 19.07.2024.
//

import Foundation

protocol SearchResultsOutput: AnyObject {
    
    func didSelectLocation(_ locationId: String)
}

@MainActor
protocol ISearchResultsPresenter: AnyObject {
    
    var searchResultViewModels: [SearchResultCellView.Model] { get }
    
    var shouldShowEmptyState: Bool { get }
        
    func performSearch()
    
    func didTapCell(atIndex index: IndexPath)
}

@MainActor
final class SearchResultsPresenter {
    
    // Dependencies
    private let searchLocationsService: ISearchLocationsService
    private let feedbackGeneratorService: IFeedbackGeneratorService
    private weak var output: SearchResultsOutput?
    weak var view: ISearchResultsView?
        
    // Models
    private(set) var searchResultViewModels = [SearchResultCellView.Model]()
    private(set) var shouldShowEmptyState: Bool = false
    private var searchResults = [SearchResultModel]()
    
    // Task management
    private var currentTask: Task<Void, Never>?
    
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
    
    private func searchLocations(text: String) async {
        do {
            let locations = try await searchLocationsService.getSearchResults(for: text)
            searchResults = locations
            searchResultViewModels = makeViewModels(from: locations)
            shouldShowEmptyState = searchResultViewModels.isEmpty
            view?.updateTableView()
        } catch {
            feedbackGeneratorService.generateFeedback(ofType: .notification(.error))
            clearState()
        }
    }

    private func makeViewModels(from models: [SearchResultModel]) -> [SearchResultCellView.Model] {
        models.map { result in
            let text = "\(result.name), \(result.country)"
            return SearchResultCellView.Model(title: text)
        }
    }
    
    private func updateSearchResults(for searchQuery: String?) async {
        guard
            let searchQuery = searchQuery,
            !searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
            searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).count > 2
        else {
            clearState()
            return
        }
        
        try? await Task.sleep(for: .seconds(0.3))
        guard !Task.isCancelled else { return }
        
        await searchLocations(
            text: searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }
    
    private func clearState() {
        shouldShowEmptyState = false
        searchResultViewModels = []
        searchResults = []
        view?.updateTableView()
    }
}

// MARK: - ISearchResultsPresenter

extension SearchResultsPresenter: ISearchResultsPresenter {
    
    func performSearch() {
        currentTask?.cancel()
        currentTask = Task { @MainActor in
            await updateSearchResults(for: view?.searchQuery)
        }
    }
    
    func didTapCell(atIndex index: IndexPath) {
        feedbackGeneratorService.generateFeedback(ofType: .impact(.medium))
        
        let locationId = String(searchResults[index.row].id)
        output?.didSelectLocation(locationId)
    }
}



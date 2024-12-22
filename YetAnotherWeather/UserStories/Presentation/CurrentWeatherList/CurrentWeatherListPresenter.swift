//
//  CurrentWeatherListPresenter.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 13.05.2024.
//

import Foundation

protocol CurrentWeatherListInput: AnyObject {
    func addToFavourites(location: String)
}

protocol CurrentWeatherListOutput: AnyObject {
    func didSelectLocation(_ location: String, isAddedToFavourites: Bool)
}

protocol ICurrentWeatherListPresenter {
    func viewDidLoad()
    func deleteLocation(atIndex index: Int)
    func didSelectRowAt(atIndex index: Int)
    func didPullToRefresh()
}

class CurrentWeatherListPresenter {
    
    // Dependencies
    private let currentWeatherService: ICurrentWeatherService
    private let viewModelFactory: ICurrentWeatherCellViewModelFactory
    private let feedbackGenerator: IFeedbackGeneratorService
    weak var output: CurrentWeatherListOutput?
    weak var view: ICurrentWeatherListView?
    
    // Models
    private var favouriteLocationsIDs = [String]()
    private var currentWeatherViewModels = [CurrentWeatherCell.Model]()

    // MARK: - Init
    
    init(
        currentWeatherService: ICurrentWeatherService,
        viewModelFactory: ICurrentWeatherCellViewModelFactory,
        feedbackGenerator: IFeedbackGeneratorService,
        output: CurrentWeatherListOutput?
    ) {
        self.currentWeatherService = currentWeatherService
        self.viewModelFactory = viewModelFactory
        self.feedbackGenerator = feedbackGenerator
        self.output = output
    }
    
    // MARK: - Private
    
    private func makeViewModels(from models: [CurrentWeatherModel]) -> [CurrentWeatherCell.Model] {
        models.map {
            viewModelFactory.makeViewModel(model: $0)
        }
    }
    
    private func getSortedCurrentWeatherItems(completionHandler: @escaping (() -> Void)) {
        currentWeatherService.getSortedCurrentWeatherItems(
            for: favouriteLocationsIDs
        ) { result in
            DispatchQueue.main.async { [weak self] in
                switch result {
                case .success(let results):
                    guard let self else { return }
                    currentWeatherViewModels = makeViewModels(from: results)
                    view?.update(with: currentWeatherViewModels)
                    completionHandler()
                case .failure(let error):
                    print("Ошибочка: \(error.localizedDescription)")
                }
            }
        }
    }
}

// MARK: - ICurrentWeatherListPresenter

extension CurrentWeatherListPresenter: ICurrentWeatherListPresenter {
    
    func viewDidLoad() {
        getSortedCurrentWeatherItems() {}
    }
    
    func didPullToRefresh() {
        guard !favouriteLocationsIDs.isEmpty else {
            view?.endRefreshing()
            return
        }
        feedbackGenerator.generateFeedback(ofType: .impact(.medium))
        getSortedCurrentWeatherItems() { [weak self] in
            self?.view?.endRefreshing()
        }
    }
    
    func deleteLocation(atIndex index: Int) {
        // дропаем из списка вью модель чтобы перерисовать таблицу
        currentWeatherViewModels.remove(at: index)
        // дропаем id локации из списка избранных городов
        // иначе при добавлении новой локиции появится удаленный город
        favouriteLocationsIDs.remove(at: index)
        view?.update(with: currentWeatherViewModels)
        feedbackGenerator.generateFeedback(ofType: .notification(.success))
    }
    
    func didSelectRowAt(atIndex index: Int) {
        output?.didSelectLocation(
            favouriteLocationsIDs[index],
            isAddedToFavourites: true
        )
        feedbackGenerator.generateFeedback(ofType: .selectionChanged)
    }
    
    func getOrderedWeatherItems() {
        currentWeatherService.getOrderedCurrentWeatherItems(
            for: favouriteLocationsIDs
        ) { result in
            DispatchQueue.main.async { [weak self] in
                switch result {
                case .success(let results):
                    let viewModels = self?.makeViewModels(from: results)
                    viewModels?.forEach {
                        print($0.location)
                    }
                case .failure(let error):
                    print("Ошибочка: \(error.localizedDescription)")
                }
            }
        }
    }
}

// MARK: - SearchResultsOutput

extension CurrentWeatherListPresenter: SearchResultsOutput {
    
    func didSelectLocation(_ location: String) {
        print("Search Results output сработал")
        output?.didSelectLocation(
            location,
            isAddedToFavourites: favouriteLocationsIDs.contains(location)
        )
    }
}

// MARK: - CurrentWeatherListInput

extension CurrentWeatherListPresenter: CurrentWeatherListInput {
    
    func addToFavourites(location: String) {
        view?.hideSearchResults()
        favouriteLocationsIDs.append(location)
        getSortedCurrentWeatherItems() {}
    }
}

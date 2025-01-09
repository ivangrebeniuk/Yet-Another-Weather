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
    func didSelectLocation(_ location: String)
}

protocol ICurrentWeatherListPresenter {
    
    func viewDidLoad()
    
    func deleteItem(atIndex index: Int)
    
    func didSelectRowAt(atIndex index: Int, section: CurrentWeatherListViewController.Section)
    
    func didPullToRefresh()
    
    func emptyState() -> Bool
    
    func viewWillDisappear()
}

class CurrentWeatherListPresenter {
    
    // Dependencies
    private let alertViewModelFactory: IAlertViewModelFactory
    private let currentWeatherService: ICurrentWeatherService
    private let viewModelFactory: ICurrentWeatherCellViewModelFactory
    private let feedbackGenerator: IFeedbackGeneratorService
    private let locationService: ILocationService
    private let searchService: ISearchLocationsService
    weak var output: CurrentWeatherListOutput?
    weak var view: ICurrentWeatherListView?
    
    // Models
    private var currentWeatherViewModels = [CurrentWeatherCell.Model]()
    private var currentLocationModel = [CurrentWeatherCell.Model]()
    private var currentLocationId: String?

    // MARK: - Init
    
    init(
        alertViewModelFactory: IAlertViewModelFactory,
        currentWeatherService: ICurrentWeatherService,
        viewModelFactory: ICurrentWeatherCellViewModelFactory,
        feedbackGenerator: IFeedbackGeneratorService,
        locationService: ILocationService,
        searchService: ISearchLocationsService,
        output: CurrentWeatherListOutput?
    ) {
        self.alertViewModelFactory = alertViewModelFactory
        self.currentWeatherService = currentWeatherService
        self.viewModelFactory = viewModelFactory
        self.feedbackGenerator = feedbackGenerator
        self.locationService = locationService
        self.searchService = searchService
        self.output = output
    }
    
    // MARK: - Private
    
    private func makeViewModels(from models: [CurrentWeatherModel]) -> [CurrentWeatherCell.Model] {
        models.map {
            viewModelFactory.makeViewModel(model: $0)
        }
    }
    
    private func getSortedCurrentWeatherItems(completionHandler: @escaping () -> Void) {
        currentWeatherService.getSortedCurrentWeatherItems { result in
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                switch result {
                case .success(let results):
                    currentWeatherViewModels = makeViewModels(from: results)
                case .failure(let error):
                    print("Ошибочка: \(error.localizedDescription)")
                    let alertModel = alertViewModelFactory.makeSingleButtonErrorAlert {}
                    view?.showAlert(with: alertModel)
                }
                view?.stopActivityIndicator()
                completionHandler()
            }
        }
    }
    
//    private func searchCurrentLocation(completionHandler: @escaping () -> Void) {
//        fetchCurrentLocation { [weak self] result in
//            guard let self = self else { return completionHandler() }
//
//            switch result {
//            case .success(let coordinates):
//                self.fetchSearchResults(for: coordinates) { [weak self] searchResult in
//                    guard let self = self else { return completionHandler() }
//
//                    switch searchResult {
//                    case .success(let locationId):
//                        self.saveAndFetchWeather(for: locationId, completionHandler: completionHandler)
//                    case .failure:
//                        completionHandler()
//                    }
//                }
//            case .failure:
//                completionHandler()
//            }
//        }
//    }
//
//    private func fetchCurrentLocation(completion: @escaping (Result<String, Error>) -> Void) {
//        locationService.getLocation { result in
//            switch result {
//            case .success(let location):
//                let coordinates = "\(location.coordinate.latitude),\(location.coordinate.longitude)"
//                completion(.success(coordinates))
//            case .failure(let error):
//                completion(.failure(error))
//            }
//        }
//    }
//
//    private func fetchSearchResults(for coordinates: String, completion: @escaping (Result<String, Error>) -> Void) {
//        searchService.getSearchResults(for: coordinates) { searchResult in
//            switch searchResult {
//            case .success(let locations):
//                guard let location = locations.last else {
//                    return completion(.failure(LocationError.locationNotAvailable))
//                }
//                completion(.success(String(location.id)))
//            case .failure(let error):
//                completion(.failure(error))
//            }
//        }
//    }
//
//    private func saveAndFetchWeather(for locationId: String, completionHandler: @escaping () -> Void) {
//        currentWeatherService.saveToFavourites(locationId, key: .currentLocationKey)
//        currentWeatherService.getCurrentWeather(for: locationId) { [weak self] result in
//            DispatchQueue.main.async {
//                guard let self = self else { return completionHandler() }
//
//                switch result {
//                case .success(let model):
//                    let viewModel = self.viewModelFactory.makeViewModel(model: model)
//                    if !self.currentLocationModel.contains(where: { $0.location == viewModel.location }) {
//                        self.currentLocationModel.append(viewModel)
//                    }
//                case .failure:
//                    let alertModel = self.alertViewModelFactory.makeSingleButtonErrorAlert() {}
//                    self.view?.showAlert(with: alertModel)
//                }
//                completionHandler()
//            }
//        }
//    }

    
    private func searchCurrentLocation(completionHandler: @escaping () -> Void) {
        locationService.getLocation { [weak self] result in
            guard let self = self else { return completionHandler() }

            // Если не удалось получить местоположение
            guard case .success(let location) = result else {
                completionHandler() // Завершаем, если не удалось получить местоположение
                return
            }

            let coordinates = "\(location.coordinate.latitude),\(location.coordinate.longitude)"

            self.searchService.getSearchResults(for: coordinates) { [weak self] searchResult in
                guard let self else { return }
                switch searchResult {
                case .success(let locations):
                    guard !locations.isEmpty, let location = locations.last else {
                        completionHandler()
                        return
                    }
                    currentLocationId = String(location.id)
                    guard let currentLocationId = currentLocationId else {
                        completionHandler()
                        return
                    }

                    currentWeatherService.saveToFavourites(currentLocationId, key: .currentLocationKey)

                    currentWeatherService.getCurrentWeather(for: currentLocationId) { result in
                        DispatchQueue.main.async { [weak self] in
                            guard let self = self else { return completionHandler() }

                            switch result {
                            case .success(let model):
                                let viewModel = self.viewModelFactory.makeViewModel(model: model)
                                if !self.currentLocationModel.contains(where: { $0.location == viewModel.location }) {
                                    self.currentLocationModel.append(viewModel)
                                }
                            case .failure(_):
                                let alertModel = self.alertViewModelFactory.makeSingleButtonErrorAlert() {}
                                self.view?.showAlert(with: alertModel)
                            }
                            completionHandler()
                        }
                    }

                case .failure(_):
                    completionHandler()
                }
            }
        }
    }

    private func updateSections(completionHandler: @escaping () -> Void) {
        let group = DispatchGroup()
        
        group.enter()
        searchCurrentLocation() {
            group.leave()
        }
        
        group.enter()
        getSortedCurrentWeatherItems() {
            group.leave()
        }
        
        group.notify(queue: .main) { [weak self] in
            guard let self else { return }
            view?.updateSections(
                for: [
                    .currentLocation: currentLocationModel,
                    .main: currentWeatherViewModels
                ]
            )
        }
    }
}

// MARK: - ICurrentWeatherListPresenter

extension CurrentWeatherListPresenter: ICurrentWeatherListPresenter {
    
    func viewDidLoad() {
        updateSections() {}
    }
    
    func didPullToRefresh() {
        guard !currentWeatherService.cachedFavourites.isEmpty else {
            view?.endRefreshing()
            return
        }
        feedbackGenerator.generateFeedback(ofType: .impact(.medium))
        getSortedCurrentWeatherItems { [weak self] in
            self?.view?.endRefreshing()
        }
    }
    
    func deleteItem(atIndex index: Int) {
        // дропаем из списка вью модель чтобы перерисовать таблицу
        currentWeatherViewModels.remove(at: index)
        // дропаем id локации из списка избранных городов
        // иначе при добавлении новой локиции появится удаленный город
        currentWeatherService.deleteFromFavourites(index, key: .favouriteLocationKey)
        view?.updateSections(
            for: [
                .currentLocation: currentLocationModel,
                .main: currentWeatherViewModels
            ]
        )
        feedbackGenerator.generateFeedback(ofType: .notification(.success))
    }
    
    func didSelectRowAt(atIndex index: Int, section: CurrentWeatherListViewController.Section) {
        switch section {
        case .main:
            output?.didSelectLocation(
                currentWeatherService.cachedFavourites[index]
            )
        case .currentLocation:
            output?.didSelectLocation(
                currentWeatherService.cachedCurrecntLocation[index]
            )
        }
        
        feedbackGenerator.generateFeedback(ofType: .selectionChanged)
    }
    
    func emptyState() -> Bool {
        return currentWeatherService.cachedFavourites.isEmpty && currentLocationModel.isEmpty
    }
    
    func viewWillDisappear() {
        currentWeatherService.deleteFromFavourites(0, key: .currentLocationKey)
    }
}

// MARK: - SearchResultsOutput

extension CurrentWeatherListPresenter: SearchResultsOutput {
    
    func didSelectLocation(_ location: String) {
        output?.didSelectLocation(location)
    }
}

// MARK: - CurrentWeatherListInput

extension CurrentWeatherListPresenter: CurrentWeatherListInput {
    
    func addToFavourites(location: String) {
        view?.hideSearchResults()
        currentWeatherService.saveToFavourites(location, key: .favouriteLocationKey)
        updateSections {}
    }
}

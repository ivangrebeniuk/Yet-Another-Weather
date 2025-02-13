//
//  CurrentWeatherListPresenter.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 13.05.2024.
//

import Foundation

protocol CurrentWeatherListInput: AnyObject {
    func addToFavourites(location: Location)
}

protocol CurrentWeatherListOutput: AnyObject {
    func didSelectLocation(_ locationId: String, isCurrentLocation: Bool)
}

protocol ICurrentWeatherListPresenter {
    
    func viewDidLoad()
    
    func deleteItem(atIndex index: Int)
    
    func didSelectRowAt(atIndex index: Int, section: CurrentWeatherListViewController.Section)
    
    func didPullToRefresh()
    
    func emptyState() -> Bool
}

class CurrentWeatherListPresenter {
    
    // Dependencies
    private let alertViewModelFactory: IAlertViewModelFactory
    private let currentWeatherService: ICurrentWeatherService
    private let viewModelFactory: ICurrentWeatherCellViewModelFactory
    private let feedbackGenerator: IFeedbackGeneratorService
    private let locationService: ILocationService
    private let searchService: ISearchLocationsService
    private let lifeCycleHandlingService: ILifecycleHandlingService
    private let favouritesService: IFavouritesService
    
    weak var output: CurrentWeatherListOutput?
    weak var view: ICurrentWeatherListView?
    
    // Models
    private var currentLocationViewModel = [CurrentWeatherCell.Model]()
    private var currentWeatherViewModels = [CurrentWeatherCell.Model]()
    private var currentLocationId: String?

    // MARK: - Init
    
    init(
        alertViewModelFactory: IAlertViewModelFactory,
        currentWeatherService: ICurrentWeatherService,
        viewModelFactory: ICurrentWeatherCellViewModelFactory,
        feedbackGenerator: IFeedbackGeneratorService,
        locationService: ILocationService,
        searchService: ISearchLocationsService,
        lifeCycleHandlingService: ILifecycleHandlingService,
        favouritesService: IFavouritesService,
        output: CurrentWeatherListOutput?
    ) {
        self.alertViewModelFactory = alertViewModelFactory
        self.currentWeatherService = currentWeatherService
        self.viewModelFactory = viewModelFactory
        self.feedbackGenerator = feedbackGenerator
        self.locationService = locationService
        self.searchService = searchService
        self.lifeCycleHandlingService = lifeCycleHandlingService
        self.favouritesService = favouritesService
        self.output = output
    }
    
    // MARK: - Private
    
    private func makeViewModels(from models: [CurrentWeatherModel]) -> [CurrentWeatherCell.Model] {
        models.map {
            viewModelFactory.makeViewModel(model: $0)
        }
    }
    
    private func getSortedCurrentWeatherItems(completionHandler: @escaping () -> Void) {
        let locations = favouritesService.cachedFavourites
        guard !locations.isEmpty else {
            return completionHandler()
        }
        currentWeatherService.getSortedCurrentWeatherItems(for: locations) { result in
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
                completionHandler()
            }
        }
    }
    
    private func fetchCurrentCoordinates(completion: @escaping (Result<String, Error>) -> Void) {
        locationService.getLocation { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let currentLocation):
                    completion(.success(currentLocation))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    private func searchCurrentLocation(
        coordinates: String,
        completion: @escaping (Result<[SearchResultModel], Error>) -> Void
    ) {
        searchService.getSearchResults(for: coordinates) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let models):
                    guard !models.isEmpty, let model = models.first else { return }
                    self?.currentLocationId = String(model.id)
                    completion(.success(models))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    private func getWeatherInCurrentLocation(
        locationId: String,
        completion: @escaping (Result<CurrentWeatherModel, Error>) -> Void
    ) {
        currentWeatherService.getCurrentWeather(for: locationId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let model):
                    completion(.success(model))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    func fetchWeatherForCurrentLocation(
        completion: @escaping (Result<CurrentWeatherCell.Model, Error>) -> Void
    ) {
        fetchCurrentCoordinates { [weak self] result in
            switch result {
            case .success(let currentLocation):
                self?.searchCurrentLocation(coordinates: currentLocation) { result in
                    switch result {
                    case .success(let searchResults):
                        // Проверяем, есть ли результаты
                        guard
                            !searchResults.isEmpty,
                            let currentLocation = searchResults.first
                        else {
                            completion(.failure(LocationError.locationNotAvailable))
                            return
                        }
                        
                        self?.getWeatherInCurrentLocation(locationId: String(currentLocation.id)) { [weak self] result in
                            guard let self else { return }
                            switch result {
                            case .success(let currentLocationWeather):
                                let viewModel = viewModelFactory.makeCurrentLocationViewModel(
                                    model: currentLocationWeather
                                )
                                completion(.success(viewModel))
                            case .failure(let error):
                                completion(.failure(error))
                            }
                        }
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    private func updateSections(completionHandler: @escaping () -> Void) {
        lifeCycleHandlingService.add(delegate: self)
                
        currentLocationViewModel.removeAll()
        currentWeatherViewModels.removeAll()
        
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        fetchWeatherForCurrentLocation { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let currentLocationWeather):
                currentLocationViewModel.append(currentLocationWeather)
                DispatchQueue.main.async {
                    self.view?.updateCurrentLocationSection(with: self.currentLocationViewModel)
                }
            case .failure(let error):
                print("Ошибка при загрузке текущей локации: \(error)")
            }
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        getSortedCurrentWeatherItems {
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            guard let self else { return }
            
            view?.updateCurrentLocationSection(with: currentLocationViewModel)
            view?.updateMainSection(with: currentWeatherViewModels)
            completionHandler()
        }
    }
}

// MARK: - ICurrentWeatherListPresenter

extension CurrentWeatherListPresenter: ICurrentWeatherListPresenter {
    
    func viewDidLoad() {
        view?.startActivityIndicator()
        updateSections() { [weak self] in
            self?.view?.stopActivityIndicator()
        }
    }
    
    func didPullToRefresh() {
        feedbackGenerator.generateFeedback(ofType: .impact(.medium))
        updateSections { [weak self] in
            self?.view?.endRefreshing()
        }
    }
    
    func deleteItem(atIndex index: Int) {
        // дропаем из списка вью модель чтобы перерисовать таблицу
        currentWeatherViewModels.remove(at: index)
        // дропаем id локации из списка избранных городов
        // иначе при добавлении новой локиции появится удаленный город
        favouritesService.deleteFromFavourites(index)
        view?.updateMainSection(with: currentWeatherViewModels)
        feedbackGenerator.generateFeedback(ofType: .notification(.success))
    }
    
    func didSelectRowAt(atIndex index: Int, section: CurrentWeatherListViewController.Section) {
        switch section {
        case .main:
            let locationId = favouritesService.cachedFavourites[index].id
            output?.didSelectLocation(
                locationId,
                isCurrentLocation: false
            )
        case .currentLocation:
            guard let currentLocationId else { return }
            output?.didSelectLocation(currentLocationId, isCurrentLocation: true)
        }
        
        feedbackGenerator.generateFeedback(ofType: .selectionChanged)
    }
    
    func emptyState() -> Bool {
        favouritesService.cachedFavourites.isEmpty && currentLocationViewModel.isEmpty
    }
}

// MARK: - SearchResultsOutput

extension CurrentWeatherListPresenter: SearchResultsOutput {
    
    func didSelectLocation(_ locationId: String) {
        guard let currentLocationId, currentLocationId == locationId else {
            output?.didSelectLocation(locationId, isCurrentLocation: false)
            return
        }
        output?.didSelectLocation(locationId, isCurrentLocation: true)
    }
}

// MARK: - CurrentWeatherListInput

extension CurrentWeatherListPresenter: CurrentWeatherListInput {
    
    func addToFavourites(location: Location) {
        view?.hideSearchResults()
        favouritesService.saveToFavourites(location) { [weak self] in
            self?.updateSections {}
        }
    }
}

// MARK: - ILifeCycleServiceDelegate

extension CurrentWeatherListPresenter: ILifeCycleServiceDelegate {
    
    func didEnterForeground() {
        updateSections() {}
    }
}

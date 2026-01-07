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
    func didSelectLocation(
        _ locationId: String,
        isCurrentLocation: Bool,
        isAddedToFavourites: Bool
    )
}

protocol ICurrentWeatherListPresenter {
    
    var shouldShowEmptyState: Bool { get }
    
    func viewDidLoad()
    
    @MainActor
    func deleteItem(atIndex index: Int) async
    
    func didSelectRowAt(atIndex index: Int, section: CurrentWeatherListViewController.Section)
    
    func didPullToRefresh()
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
    private var favouriteLocationsIDs = [Location]()
    
    private var cachedFavourites: [Location] = []

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
    
    private func updateCachedFavourites() async {
        cachedFavourites = await favouritesService.cachedFavourites()
    }
    
    private func getSortedCurrentWeatherItems(completionHandler: @escaping () -> Void) {
        favouriteLocationsIDs = cachedFavourites
        guard !favouriteLocationsIDs.isEmpty else {
            return completionHandler()
        }
        currentWeatherService.getSortedCurrentWeatherItems(for: favouriteLocationsIDs) { result in
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
                    print("✅ Получены координаты: \(currentLocation)")
                    completion(.success(currentLocation))
                case .failure(let error):
                    print("❌ Ошибка получения координат: \(error)")
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
                    print("❌ Ошибка поиска локации: \(error)")
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
            guard let self else {
                completion(.failure(LocationError.deniedError))
                return
            }
            
            switch result {
            case .success(let currentLocation):
                print("✅ Координаты получены: \(currentLocation)")
                self.searchCurrentLocation(coordinates: currentLocation) { result in
                    switch result {
                    case .success(let searchResults):
                        guard !searchResults.isEmpty, let currentLocation = searchResults.first else {
                            print("❌ Ошибка: пустые результаты поиска")
                            completion(.failure(LocationError.locationNotAvailable))
                            return
                        }
                        
                        self.getWeatherInCurrentLocation(locationId: String(currentLocation.id)) { result in
                            switch result {
                            case .success(let currentLocationWeather):
                                let viewModel = self.viewModelFactory.makeCurrentLocationViewModel(
                                    model: currentLocationWeather
                                )
                                print("✅ Погода успешно загружена")
                                completion(.success(viewModel))
                            case .failure(let error):
                                print("❌ Ошибка загрузки погоды: \(error)")
                                completion(.failure(error))
                            }
                        }
                    case .failure(let error):
                        print("❌ Ошибка поиска локации: \(error)")
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                print("❌ Ошибка получения координат: \(error)")
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
            guard let self else {
                dispatchGroup.leave()
                return
            }
            switch result {
            case .success(let currentLocationWeather):
                currentLocationViewModel.append(currentLocationWeather)
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    view?.updateCurrentLocationSection(with: currentLocationViewModel)
                }
            case .failure(let error):
                print("Ошибка при загрузке текущей локации: \(error)")
                view?.updateCurrentLocationSection(with: [])
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
    
    @MainActor
    var shouldShowEmptyState: Bool {
        cachedFavourites.isEmpty && currentLocationViewModel.isEmpty
    }
    
    func viewDidLoad() {
        view?.startActivityIndicator()
        Task { @MainActor in
            await updateCachedFavourites()
            updateSections() {}
            view?.stopActivityIndicator()
        }
    }
    
    func didPullToRefresh() {
        feedbackGenerator.generateFeedback(ofType: .impact(.medium))
        updateSections { [weak self] in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                self?.view?.endRefreshing()
            }
        }
    }
    @MainActor
    func deleteItem(atIndex index: Int) async {
        // дропаем из списка вью модель чтобы перерисовать таблицу
        // дропаем id локации из списка избранных городов
        // иначе при добавлении новой локиции появится удаленный город
        do {
            try await favouritesService.deleteFromFavourites(index)
            await updateCachedFavourites()
            currentWeatherViewModels.remove(at: index)
            view?.updateMainSection(with: currentWeatherViewModels)
            feedbackGenerator.generateFeedback(ofType: .notification(.success))
        } catch {
            let alert = alertViewModelFactory.makeSingleButtonErrorAlert {}
            view?.showAlert(with: alert)
        }
    }
    
    func didSelectRowAt(atIndex index: Int, section: CurrentWeatherListViewController.Section) {
        switch section {
        case .main:
            let locationId = cachedFavourites[index].id
            output?.didSelectLocation(
                locationId,
                isCurrentLocation: false,
                isAddedToFavourites: true
            )
        case .currentLocation:
            guard let currentLocationId else { return }
            output?.didSelectLocation(currentLocationId, isCurrentLocation: true, isAddedToFavourites: true)
        }
        
        feedbackGenerator.generateFeedback(ofType: .selectionChanged)
    }
}

// MARK: - SearchResultsOutput

extension CurrentWeatherListPresenter: SearchResultsOutput {
    
    func didSelectLocation(_ locationId: String) {
        guard let currentLocationId, currentLocationId == locationId else {
            let isAddedToFavorites = cachedFavourites.contains(where: { $0.id == locationId })
                
            output?.didSelectLocation(
                locationId,
                isCurrentLocation: false,
                isAddedToFavourites: isAddedToFavorites
            )
            return
        }
        output?.didSelectLocation(locationId, isCurrentLocation: true, isAddedToFavourites: false)
    }
}

// MARK: - CurrentWeatherListInput

extension CurrentWeatherListPresenter: CurrentWeatherListInput {
    
    func addToFavourites(location: Location) {
        view?.hideSearchResults()
        Task { @MainActor [weak self] in
            guard let self else { return }
            do {
                try await favouritesService.saveToFavourites(location)
                await updateCachedFavourites()
                updateSections() {}
            } catch {
                let alert = alertViewModelFactory.makeSingleButtonErrorAlert {}
                view?.showAlert(with: alert)
            }
        }
    }
}

// MARK: - ILifeCycleServiceDelegate

extension CurrentWeatherListPresenter: ILifeCycleServiceDelegate {
    
    func didEnterForeground() {
        updateSections() {}
    }
}

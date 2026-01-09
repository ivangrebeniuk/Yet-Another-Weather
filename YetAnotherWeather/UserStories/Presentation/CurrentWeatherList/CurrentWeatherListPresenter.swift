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
    
    func shouldShowEmptyState() async -> Bool
    
    func viewDidLoad()
    
    @MainActor
    func deleteItem(atIndex index: Int) async
    
    @MainActor
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
    
//    private var cachedFavourites: [Location] = []

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
    
    private func makeViewModels(
        from models: [CurrentWeatherModel]
    ) -> [CurrentWeatherCell.Model] {
        models.map {
            viewModelFactory.makeViewModel(model: $0)
        }
    }
    
    private func updateSections() {
        lifeCycleHandlingService.add(delegate: self)
        currentLocationViewModel.removeAll()
        currentWeatherViewModels.removeAll()
        
        Task {
            await getWeatherInCurrentLocation()
            await fetchWeatherForAllCities()
        }
    }
    
    private func fetchCurrentCoordinates() async throws -> String {
        try await locationService.getLocation()
    }
    
    private func searchCurrentLocation(coordinates: String) async throws -> [SearchResultModel] {
        try await searchService.getSearchResults(for: coordinates)
    }
    
    private func fetchWeatherInCurrentLocation(locationId: String) async throws -> CurrentWeatherModel {
        try await currentWeatherService.getCurrentWeather(for: locationId)
    }
    
    private func fetchWeatherForAllCities() async {
        favouriteLocationsIDs = await favouritesService.cachedFavourites()
        guard !favouriteLocationsIDs.isEmpty else {
            return
        }
        do {
            let weatherItems = try await currentWeatherService.getSortedCurrentWeatherItems(
                for: favouriteLocationsIDs
            )
            
            currentWeatherViewModels = makeViewModels(from: weatherItems)
            
            await MainActor.run { [weak self] in
                guard let self else { return }
                view?.updateMainSection(with: currentWeatherViewModels)
            }
        } catch {
            await MainActor.run { [weak self] in
                guard let self else { return }
                let alertModel = alertViewModelFactory.makeSingleButtonErrorAlert {}
                view?.showAlert(with: alertModel)
            }
        }
    }

    private func getWeatherInCurrentLocation() async {
        do {
            currentLocationViewModel.removeAll()
            let coordinates = try await fetchCurrentCoordinates()
            let locations = try await searchCurrentLocation(coordinates: coordinates)
            
            guard
                !locations.isEmpty,
                let locationId = locations.first?.id
            else { return }
            
            currentLocationId = String(locationId)
            
            let currentWeather = try await fetchWeatherInCurrentLocation(locationId: String(locationId))
            
            let viewModel = viewModelFactory.makeCurrentLocationViewModel(model: currentWeather)
            currentLocationViewModel.append(viewModel)
            await MainActor.run {
                view?.updateCurrentLocationSection(with: currentLocationViewModel)
            }
        } catch {
            await MainActor.run {
                view?.updateCurrentLocationSection(with: [])
            }
        }
    }
}

// MARK: - ICurrentWeatherListPresenter

extension CurrentWeatherListPresenter: ICurrentWeatherListPresenter {
    
    func shouldShowEmptyState() async -> Bool {
        let isCachedFavouritesEmpty = await favouritesService.cachedFavourites().isEmpty
        return await MainActor.run {
            isCachedFavouritesEmpty && currentLocationViewModel.isEmpty
        }
    }
   
    
    func viewDidLoad() {
        view?.startActivityIndicator()
        updateSections()
        view?.stopActivityIndicator()
    }
    
    func didPullToRefresh() {
        feedbackGenerator.generateFeedback(ofType: .impact(.medium))
        updateSections()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.view?.endRefreshing()
        }
    }
    
    @MainActor
    func deleteItem(atIndex index: Int) async {
        // дропаем из списка вью модель чтобы перерисовать таблицу
        // дропаем id локации из списка избранных городов
        // иначе при добавлении новой локиции появится удаленный город
        do {
            try await favouritesService.deleteFromFavourites(index)
            currentWeatherViewModels.remove(at: index)
            view?.updateMainSection(with: currentWeatherViewModels)
            feedbackGenerator.generateFeedback(ofType: .notification(.success))
        } catch {
            let alert = alertViewModelFactory.makeSingleButtonErrorAlert {}
            view?.showAlert(with: alert)
        }
    }
    
    @MainActor
    func didSelectRowAt(atIndex index: Int, section: CurrentWeatherListViewController.Section) {
        Task {
            switch section {
            case .main:
                let locationId = await favouritesService.cachedFavourites()[index].id
                output?.didSelectLocation(
                    locationId,
                    isCurrentLocation: false,
                    isAddedToFavourites: true
                )
            case .currentLocation:
                guard let currentLocationId else { return }
                output?.didSelectLocation(
                    currentLocationId,
                    isCurrentLocation: true,
                    isAddedToFavourites: true
                )
            }
            
            feedbackGenerator.generateFeedback(ofType: .selectionChanged)
        }
    }
}

// MARK: - SearchResultsOutput

extension CurrentWeatherListPresenter: SearchResultsOutput {
    
    func didSelectLocation(_ locationId: String) {
        Task {
            var isCurrentLocation: Bool
            var isAddedToFavorites: Bool
            
            if let currentLocationId, currentLocationId == locationId {
                isCurrentLocation = true
                isAddedToFavorites = true
            } else {
                isCurrentLocation = false
                isAddedToFavorites = await favouritesService.isFavourite(locationId)
            }
            await MainActor.run { [weak self, isCurrentLocation, isAddedToFavorites] in
                guard let self else { return }
                output?.didSelectLocation(
                    locationId,
                    isCurrentLocation: isCurrentLocation,
                    isAddedToFavourites: isAddedToFavorites
                )
            }
        }
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
                updateSections()
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
        updateSections()
    }
}

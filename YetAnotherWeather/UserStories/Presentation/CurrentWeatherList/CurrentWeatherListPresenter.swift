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
    
    func didSelectRowAt(atIndex index: Int)
    
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
    weak var output: CurrentWeatherListOutput?
    weak var view: ICurrentWeatherListView?
    
    // Models
    private var currentWeatherViewModels = [CurrentWeatherCell.Model]()
    private var currentLocationModel = [CurrentWeatherCell.Model]()

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
    
    deinit {
        currentWeatherService.deleteFromFavourites(0)
    }
    
    // MARK: - Private
    
    private func makeViewModels(from models: [CurrentWeatherModel]) -> [CurrentWeatherCell.Model] {
        models.map {
            viewModelFactory.makeViewModel(model: $0)
        }
    }
    
//    private func getSortedCurrentWeatherItems(completionHandler: @escaping () -> Void) {
//        currentWeatherService.getSortedCurrentWeatherItems { result in
//            DispatchQueue.main.async { [weak self] in
//                guard let self else { return }
//                switch result {
//                case .success(let results):
//                    currentWeatherViewModels = makeViewModels(from: results)
//                    view?.update(with: currentWeatherViewModels)
//                case .failure(let error):
//                    print("Ошибочка: \(error.localizedDescription)")
//                    if error._code == NSURLErrorNotConnectedToInternet {
//                        let alertModel = alertViewModelFactory.makeNoInternetConnectionAlert() {}
//                        view?.showAlert(with: alertModel)
//                    } else {
//                        let alertModel = alertViewModelFactory.makeSingleButtonErrorAlert() {}
//                        view?.showAlert(with: alertModel)
//                    }
//                }
//                view?.stopActivityIndicator()
//                completionHandler()
//            }
//        }
//    }
    
    private func getSortedCurrentWeatherItems(completionHandler: @escaping () -> Void) {
        currentWeatherService.getSortedCurrentWeatherItems { result in
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                switch result {
                case .success(let results):
                    currentWeatherViewModels = makeViewModels(from: results)
//                    view?.update(with: currentWeatherViewModels)
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
    
    private func searchCurrentLocation(completionHandler: @escaping () -> Void) {
        locationService.getLocation { [weak self] result in
            guard let self = self else { return completionHandler() }
            
            // Если не удалось получить местоположение
            guard case .success(let location) = result else {
                completionHandler() // Завершаем, если не удалось получить местоположение
                return
            }
            
            let coordinates = "\(location.coordinate.latitude),\(location.coordinate.longitude)"
            
            self.searchService.getSearchResults(for: coordinates) { searchResult in
                switch searchResult {
                case .success(let locations):
                    guard !locations.isEmpty, let firstLocation = locations.last else {
                        completionHandler() // Завершаем, если список местоположений пуст
                        return
                    }
                    
                    let currentLocationId = String(firstLocation.id)
                    
                    self.currentWeatherService.getCurrentWeather(for: currentLocationId) { result in
                        DispatchQueue.main.async { [weak self] in
                            guard let self = self else { return completionHandler() }
                            
                            switch result {
                            case .success(let model):
                                let viewModel = self.viewModelFactory.makeViewModel(model: model)
                                self.currentLocationModel.append(viewModel)
                            case .failure(_):
                                let alertModel = self.alertViewModelFactory.makeSingleButtonErrorAlert() {}
                                self.view?.showAlert(with: alertModel)
                            }
                            completionHandler() // Завершаем операцию по окончании всех запросов
                        }
                    }
                    
                case .failure(_):
                    completionHandler() // Завершаем, если не удалось выполнить поиск
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
        currentWeatherService.deleteFromFavourites(index)
//        view?.update(with: currentWeatherViewModels)
        view?.updateSections(
            for: [
                .currentLocation: currentLocationModel,
                .main: currentWeatherViewModels
            ]
        )
        feedbackGenerator.generateFeedback(ofType: .notification(.success))
    }
    
    func didSelectRowAt(atIndex index: Int) {
        output?.didSelectLocation(
            currentWeatherService.cachedFavourites[index]
        )
        feedbackGenerator.generateFeedback(ofType: .selectionChanged)
    }
    
    func emptyState() -> Bool {
        return currentWeatherService.cachedFavourites.isEmpty && currentLocationModel.isEmpty
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
        currentWeatherService.saveToFavourites(location)
        updateSections {}
    }
}

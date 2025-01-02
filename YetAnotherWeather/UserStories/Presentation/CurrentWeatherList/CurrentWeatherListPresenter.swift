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
    weak var output: CurrentWeatherListOutput?
    weak var view: ICurrentWeatherListView?
    
    // Models
    private var currentWeatherViewModels = [CurrentWeatherCell.Model]()

    // MARK: - Init
    
    init(
        alertViewModelFactory: IAlertViewModelFactory,
        currentWeatherService: ICurrentWeatherService,
        viewModelFactory: ICurrentWeatherCellViewModelFactory,
        feedbackGenerator: IFeedbackGeneratorService,
        output: CurrentWeatherListOutput?
    ) {
        self.alertViewModelFactory = alertViewModelFactory
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
    
    private func getSortedCurrentWeatherItems(completionHandler: @escaping () -> Void) {
        view?.startActivityIndicator()
        currentWeatherService.getSortedCurrentWeatherItems { result in
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                switch result {
                case .success(let results):
                    currentWeatherViewModels = makeViewModels(from: results)
                    view?.update(with: currentWeatherViewModels)
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
}

// MARK: - ICurrentWeatherListPresenter

extension CurrentWeatherListPresenter: ICurrentWeatherListPresenter {
    
    func viewDidLoad() {
        getSortedCurrentWeatherItems {}
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
        view?.update(with: currentWeatherViewModels)
        feedbackGenerator.generateFeedback(ofType: .notification(.success))
    }
    
    func didSelectRowAt(atIndex index: Int) {
        output?.didSelectLocation(
            currentWeatherService.cachedFavourites[index]
        )
        feedbackGenerator.generateFeedback(ofType: .selectionChanged)
    }
    
    func emptyState() -> Bool {
        return currentWeatherService.cachedFavourites.isEmpty
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
        getSortedCurrentWeatherItems() {}
    }
}

//
//  CurrentWeatherListCoordinator.swift
//  YetAnotherWeather
//
//  Created by Иван Гребенюк on 19.05.2024.
//

import Foundation
import UIKit

final class CurrentWeatherListCoordinator {
    
    private let currentWeatherListAssembly: CurrentWeatherListAssembly
    private let weatherDetailsAssembly: WeatherDetailsAssembly
    private weak var navigationController: UIViewController?
        
    init(
        currentWeatherListAssembly: CurrentWeatherListAssembly,
        weatherDetailsAssembly: WeatherDetailsAssembly
    ) {
        self.currentWeatherListAssembly = currentWeatherListAssembly
        self.weatherDetailsAssembly = weatherDetailsAssembly
    }
    
    func start(with navigationController: UINavigationController) {
        let viewController = currentWeatherListAssembly.assemble(output: self)
        
        self.navigationController = navigationController
        navigationController.pushViewController(viewController, animated: true)
    }
    
    // MARK: - Private
    // Делегат - это CurrentWeatherListPresenter
    private func openWeatherDetails(for location: String, output: IWeatherDetailsOutput) {
        let weatherDetailsViewController = weatherDetailsAssembly.assemble(
            location: location,
            output: output
        )
        navigationController?.present(
            UINavigationController(rootViewController: weatherDetailsViewController),
            animated: true
        )
    }
    
    // Делегат - это CurrentWeatherListCoordinator
    
    // Добавить weatherDetailsFlowCoordinator, у него будет 3 метода: закрыть и добавить в favourites и start
    // Для input смотри на класс Module в МБ. Надо чтобы assemble возвращал 1. uiviewcontroller 2. input
    // Не обязательно делать Module дженериком
//    private func openWeatherDetails(for location: String) {
//        let weatherDetailsViewController = weatherDetailsAssembly.assemble(
//            location: location,
//            output: self
//        )
//        navigationController?.present(
//            UINavigationController(rootViewController: weatherDetailsViewController),
//            animated: true
//        )
//    }
}

extension CurrentWeatherListCoordinator: IWeatherDetailsOutput {
    func didAddLocationToFavourites(location: String?) {
        self.navigationController?.presentingViewController?.dismiss(animated: true)
    }
}

// MARK: - CurrentWeatherListOutput

extension CurrentWeatherListCoordinator: CurrentWeatherListOutput {
    func didSelectLocation(_ location: String, output: IWeatherDetailsOutput) {
        // Аутпут - это презентер
        openWeatherDetails(for: location, output: output)
        // Аутпут - это флоу координатор (так должно быть)
//        openWeatherDetails(for: location)

    }
}

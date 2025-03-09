//
//  CurrentWeatherCellViewModelFactoryMock.swift
//  YetAnotherWeatherTests
//
//  Created by Иван Гребенюк on 08.03.2025.
//

import Foundation
@testable import YetAnotherWeather

final class CurrentWeatherCellViewModelFactoryMock: ICurrentWeatherCellViewModelFactory {

    var invokedMakeCurrentLocationViewModel = false
    var invokedMakeCurrentLocationViewModelCount = 0
    var invokedMakeCurrentLocationViewModelParameters: (model: CurrentWeatherModel, Void)?
    var invokedMakeCurrentLocationViewModelParametersList = [(model: CurrentWeatherModel, Void)]()
    var stubbedMakeCurrentLocationViewModelResult: CurrentWeatherCell.Model!

    func makeCurrentLocationViewModel(model: CurrentWeatherModel) -> CurrentWeatherCell.Model {
        invokedMakeCurrentLocationViewModel = true
        invokedMakeCurrentLocationViewModelCount += 1
        invokedMakeCurrentLocationViewModelParameters = (model, ())
        invokedMakeCurrentLocationViewModelParametersList.append((model, ()))
        return stubbedMakeCurrentLocationViewModelResult
    }

    var invokedMakeViewModel = false
    var invokedMakeViewModelCount = 0
    var invokedMakeViewModelParameters: (model: CurrentWeatherModel, Void)?
    var invokedMakeViewModelParametersList = [(model: CurrentWeatherModel, Void)]()
    var stubbedMakeViewModelResult: CurrentWeatherCell.Model!

    func makeViewModel(model: CurrentWeatherModel) -> CurrentWeatherCell.Model {
        invokedMakeViewModel = true
        invokedMakeViewModelCount += 1
        invokedMakeViewModelParameters = (model, ())
        invokedMakeViewModelParametersList.append((model, ()))
        return stubbedMakeViewModelResult
    }
}

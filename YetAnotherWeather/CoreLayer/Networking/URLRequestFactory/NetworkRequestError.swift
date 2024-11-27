//
//  NetworkRequestError.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 09.06.2024.
//

import Foundation

enum NetworkRequestError: Error {
    case invalidURL
    case endpointError
    case modelParsingError
    case searchParsingError
    case currentWeatherParsingError
    case windParsingError
    case locationParsingError
    case forecastParsingError
}

extension NetworkRequestError: LocalizedError {
    
    // MARK: - LocalizedError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Не удалось преобразовать String в URL"
        case .endpointError:
            return "Не удалось создать URL"
        case .modelParsingError:
            return "Не удалось распарсить данные"
        case .searchParsingError:
            return "Не удалось распарсить данные для модели SearchModel"
        case .currentWeatherParsingError:
            return "Не удалось распарсить данные для модели CurrentWeatherModel"
        case .windParsingError:
            return "Не удалось распарсить данные для модели CurrentWeatherModel.Wind"
        case .locationParsingError:
            return "Не удалось распарсить данные для модели CurrentWeatherModel.Location"
        case .forecastParsingError:
            return "Не удалось распарсить данные для модели ForecastModel"
        }
    }
}

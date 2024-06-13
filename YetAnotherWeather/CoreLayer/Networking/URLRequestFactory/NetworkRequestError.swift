//
//  NetworkRequestError.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 09.06.2024.
//

import Foundation

enum NetworkRequestError: LocalizedError {
    case invalidURL
    case endpointError
    
    var errorDescription: String {
        switch self {
        case .invalidURL:
            "Не удалось преобразовать String в URL"
        case .endpointError:
            "Не удалось создать URL"
        }
    }
}

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
        }
    }
}

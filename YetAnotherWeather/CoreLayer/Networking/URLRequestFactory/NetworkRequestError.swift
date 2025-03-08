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
    case modelParsingError(Any.Type)
    case invalidData
    case unknown
    case serverError
}

extension NetworkRequestError: LocalizedError {
    
    // MARK: - LocalizedError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Не удалось преобразовать String в URL"
        case .endpointError:
            return "Не удалось создать URL"
        case .modelParsingError(let type):
            return "Не удалось распарсить данные: \(type)"
        case .invalidData:
            return "Нет данных в ответе"
        case .unknown:
            return "❌ Не удалось получить HTTPResponse"
        case .serverError:
            return "❌ Ошибка сервера"
        }
    }
}

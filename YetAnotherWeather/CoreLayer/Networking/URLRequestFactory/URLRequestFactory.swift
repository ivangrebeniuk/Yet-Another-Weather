//
//  URLRequestFactory.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 08.06.2024.
//

import Foundation

final class URLRequestFactory {
    
    // Static
    private static var apiKey: String {
        let apiKey = Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String
        return apiKey ?? ""
    }
    
    // MARK: - Model
    
    private struct Endpoint {
        let path: String
        let querryItems: [URLQueryItem]
        
        var url: URL? {
            var components = URLComponents()
            components.scheme = APIConstants.scheme
            components.host = APIConstants.host
            components.path = path
            components.queryItems = [
                URLQueryItem(name: "key", value: URLRequestFactory.apiKey),
                URLQueryItem(name: "lang", value: "eng")
            ] + querryItems
            
            return components.url
        }
    }
}

// MARK: - IURLRequestFactory

extension URLRequestFactory: IURLRequestFactory {
    
    func makeSearchRequest(for location: String) throws -> URLRequest {
        let querryItems = [
            URLQueryItem(name: APIConstants.location, value: location)
        ]
        guard let url = Endpoint(path: APIConstants.searchPath, querryItems: querryItems).url else {
            throw NetworkRequestError.endpointError
        }
        return URLRequest(url: url)
    }

    func makeCurrentWeatherRequest(for location: String) throws -> URLRequest {
        let querryItems = [
            URLQueryItem(name: APIConstants.location, value: "id:\(location)")
        ]
        guard let url = Endpoint(path: APIConstants.currentPath, querryItems: querryItems).url else {
            throw NetworkRequestError.endpointError
        }
        return URLRequest(url: url)
    }
    
    func makeForecastRequest(for location: String) throws -> URLRequest {
        let querryItems = [
            URLQueryItem(name: APIConstants.location, value: "id:\(location)"),
            URLQueryItem(name: APIConstants.daysParameter, value: "7")
        ]
        guard let url = Endpoint(
            path: APIConstants.forecastPath,
            querryItems: querryItems
        ).url else {
            throw NetworkRequestError.endpointError
        }
        return URLRequest(url: url)
    }
}

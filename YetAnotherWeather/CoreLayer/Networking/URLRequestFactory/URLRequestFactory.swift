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
        let arguments = ProcessInfo.processInfo.arguments
        let environment = ProcessInfo.processInfo.environment
        
        var url: URL? {
            var components = URLComponents()
            components.path = path
            components.queryItems = [
                URLQueryItem(name: "key", value: URLRequestFactory.apiKey),
                URLQueryItem(name: "lang", value: "eng")
            ] + querryItems
            
            
            if
                arguments.contains("isUITesting"),
                let portString = environment["MOCK_SERVER_PORT"],
                let port = UInt16(portString) {
                print("✅ UI tests launched at port \(port)")
                components.scheme = "http"
                components.host = "localhost"
                components.port = Int(port)
                
            } else {
                components.scheme = APIConstants.scheme
                components.host = APIConstants.host
            }
            
            let finalURL = components.url
            
            return finalURL
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

//
//  NetworkService.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 10.06.2024.
//

import Foundation
import SwiftyJSON

protocol INetworkService: AnyObject {
    /// Send network request and parse JSON into `model`
    /// Uses `static func from`
    func loadModel<T: JSONParsable>(
        request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    )
    
    /// Send network request and parse JSON into `[model]`
    /// Uses `static func fromArray`
    func loadModels<T: JSONParsable>(
        request: URLRequest,
        completion: @escaping (Result<[T], Error>) -> Void
    )
    
    /// Send network request and parse JSON into `model`
    /// Uses `JSONParser`
    func load<JSONParser: IJSONParser, Model>(
        request: URLRequest,
        parser: JSONParser,
        completion: @escaping (Result<Model, Error>) -> Void
    ) where JSONParser.Model == Model
    
    func load<JSONParser: IJSONParser, Model>(
        request: URLRequest,
        parser: JSONParser
    ) async throws -> Model where JSONParser.Model == Model
}


final class NetworkService: INetworkService {
    
    private let session: URLSession
    
    // MARK: - Init
    
    init(session: URLSession) {
        self.session = session
    }
    
    // MARK: - INetworkService
    
    func loadModel<T: JSONParsable>(
        request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        session.dataTask(with: request) { (data, response, error) in
            
            if let error = error {
                print("❌ Ошибка при сетевом запросе: \(error)")
                completion(.failure(error))
                return
            }

            guard let data = data else {
                print("❌ Нет данных в ответе")
                completion(.failure(NetworkRequestError.invalidData))
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                print("❌ Не удалось получить HTTPResponse")
                completion(.failure(NetworkRequestError.unknown))
                return
            }
            
            guard response.statusCode == 200 else {
                print("❌ Ошибка сервера с кодом \(response.statusCode)")
                completion(.failure(NetworkRequestError.serverError))
                return
            }

            guard let model = T.from(JSON(data)) else {
                print("❌ Ошибка парсинга данных")
                completion(.failure(NetworkRequestError.invalidData))
                return
            }

            completion(.success(model))
        }.resume()
    }
    
    func loadModels<T: JSONParsable>(
        request: URLRequest,
        completion: @escaping (Result<[T], Error>) -> Void
    ) {
        session.dataTask(with: request) { (data, response, error) in
            
            if let error = error {
                print("❌ Ошибка при сетевом запросе: \(error)")
                completion(.failure(error))
                return
            }

            guard let data = data else {
                print("❌ Нет данных в ответе")
                completion(.failure(NetworkRequestError.invalidData))
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                print("❌ Не удалось получить HTTPResponse")
                completion(.failure(NetworkRequestError.unknown))
                return
            }
            
            guard response.statusCode == 200 else {
                print("❌ Ошибка сервера с кодом \(response.statusCode)")
                completion(.failure(NetworkRequestError.serverError))
                return
            }

            guard let models = T.fromArray(JSON(data)) else {
                print("❌ Ошибка парсинга массива данных")
                completion(.failure(NetworkRequestError.invalidData))
                return
            }

            completion(.success(models))
        }.resume()
    }
    
    func load<JSONParser: IJSONParser, Model>(
        request: URLRequest,
        parser: JSONParser,
        completion: @escaping (Result<Model, Error>) -> Void
    ) where JSONParser.Model == Model {
        session.dataTask(with: request) { (data, response, error) in
            
            if let error = error {
                print("❌ Ошибка при сетевом запросе: \(error)")
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                print("❌ Нет данных в ответе")
                completion(.failure(NetworkRequestError.invalidData))
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                print("❌ Не удалось получить HTTPResponse")
                completion(.failure(NetworkRequestError.unknown))
                return
            }
            
            guard response.statusCode == 200 else {
                print("❌ Ошибка сервера с кодом \(response.statusCode)")
                completion(.failure(NetworkRequestError.serverError))
                return
            }
            
            do {
                let parsedData = try parser.parse(JSON(data))
                completion(.success(parsedData))
            } catch {
                print("❌ Ошибка парсинга данных: \(error)")
                completion(.failure(error))
                return
            }
        }.resume()
    }
    
    // MARK: - Modern Concurrency
    
    func load<JSONParser, Model>(
        request: URLRequest,
        parser: JSONParser
    ) async throws -> Model where JSONParser : IJSONParser, Model == JSONParser.Model {
        let (data, response) = try await session.data(for: request)
        
        guard
            let response = response as? HTTPURLResponse,
            (200...300).contains(response.statusCode)
        else {
            throw NetworkRequestError.serverError
        }
        
        let parsedModel = try parser.parse(JSON(data))
        
        return parsedModel
    }
}

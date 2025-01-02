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
                completion(.failure(error))
                return
            }

            guard
                let data = data,
                let model = T.from(JSON(data)),
                let response = response as? HTTPURLResponse,
                response.statusCode == 200 else {
                completion(.failure(NetworkRequestError.invalidURL))
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
                completion(.failure(error))
            }
            
            guard
                let data = data,
                let models = T.fromArray(JSON(data)),
                let response = response as? HTTPURLResponse,
                response.statusCode == 200 else {
                completion(.failure(NetworkRequestError.invalidURL))
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
                completion(.failure(error))
                return
            }
            
            guard
                let data = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200 else {
                completion(.failure(NetworkRequestError.invalidURL))
                return
            }
            
            do {
                let parsedData = try parser.parse(JSON(data))
                completion(.success(parsedData))
            } catch {
                completion(.failure(error))
                return
            }
        }.resume()
    }
}

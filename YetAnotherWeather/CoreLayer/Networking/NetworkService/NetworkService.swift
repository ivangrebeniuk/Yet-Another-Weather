//
//  NetworkService.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 10.06.2024.
//

import Foundation
import SwiftyJSON

protocol INetworkService: AnyObject {
    /// Send network request
    func performRequest<T: JSONParsable>(with request: URLRequest, completion: @escaping (Result<T, Error>) -> Void)
}

final class NetworkService: INetworkService {
    
    private let session: URLSession
    
    // MARK: - Init
    
    init(session: URLSession) {
        self.session = session
    }
    
    // MARK: - INetworkService
    
    func performRequest<T: JSONParsable>(
        with request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        session.dataTask(with: request) { (data, response, error) in
            
            if let error = error {
                completion(.failure(error))
            }
            
            guard let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completion(.failure(NetworkRequestError.invalidURL))
                return
            }
            
            guard let model = try? T.from(JSON(data: data)) else {
                return completion(.failure(NetworkRequestError.endpointError))
            }
            
            completion(.success(model))
        }.resume()
    }
    
}

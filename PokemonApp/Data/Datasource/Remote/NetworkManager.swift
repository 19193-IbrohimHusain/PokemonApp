//
//  NetworkManager.swift
//  PokemonApp
//
//  Created by Ibrohim Husain on 14/08/25.
//

import Foundation
import Combine

protocol NetworkRequest {
    func fetchDecodable<T: Decodable>(_ endpoint: Endpoint, timeout: TimeInterval) -> AnyPublisher<T, Error>
}

enum NetworkError: Error {
    case invalidURL
    case requestBuildFailed
    case noHTTPResponse
    case server(status: Int, data: Data?)
    case emptyData
}

final class NetworkManager: NetworkRequest {
    static let shared = NetworkManager()
    
    private init() {}
    
    func fetchDecodable<T: Decodable>(_ endpoint: Endpoint, timeout: TimeInterval = 60) -> AnyPublisher<T, Error> {
        guard var components = URLComponents(string: endpoint.fullPath) else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        if endpoint.method == .get, let params = endpoint.parameter {
            let items: [URLQueryItem] = params.map {
                URLQueryItem(name: $0, value: String(describing: $1))
            }
            components.queryItems = (components.queryItems ?? []) + items
        }
        
        guard let url = components.url else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url, timeoutInterval: timeout)
        request.httpMethod = endpoint.method.rawValue
        
        if let headers = endpoint.header {
            headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        }
        
        if endpoint.method != .get, let params = endpoint.parameter {
            if request.value(forHTTPHeaderField: "Content-Type") == nil {
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: params, options: [])
            } catch {
                return Fail(error: NetworkError.requestBuildFailed).eraseToAnyPublisher()
            }
        }
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = timeout
        config.timeoutIntervalForResource = timeout
        let session = URLSession(configuration: config)
        return session.dataTaskPublisher(for: request)
            .tryMap { [weak self] in
                guard let _ = self else { throw NetworkError.noHTTPResponse }
                guard let http = $1 as? HTTPURLResponse else {
                    throw NetworkError.noHTTPResponse
                }
                guard (200..<300).contains(http.statusCode) else {
                    throw NetworkError.server(status: http.statusCode, data: $0)
                }
                guard !$0.isEmpty else {
                    throw NetworkError.emptyData
                }
                return $0
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}


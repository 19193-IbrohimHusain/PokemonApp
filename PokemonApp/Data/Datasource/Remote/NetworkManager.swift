//
//  NetworkManager.swift
//  PokemonApp
//
//  Created by Ibrohim Husain on 14/08/25.
//

import Alamofire
import Combine

protocol NetworkRequest {
    func fetchDecodable<T: Decodable>(_ endpoint: Endpoint, timeout: TimeInterval) -> AnyPublisher<T, Error>
}

final class NetworkManager: NetworkRequest {
    static let shared = NetworkManager()
    
    private init() {}
    
    func fetchDecodable<T: Decodable>(_ endpoint: Endpoint, timeout: TimeInterval = 60) -> AnyPublisher<T, Error> {
        let request = AF.request(
            endpoint.fullPath,
            method: endpoint.method,
            parameters: endpoint.parameter,
            headers: endpoint.header,
            requestModifier: { $0.timeoutInterval = timeout }
        )
        
        return request
            .validate()
            .publishDecodable(type: T.self)
            .value()
            .mapError { $0 as Error }
            .handleEvents(receiveCancel: { request.cancel() })
            .eraseToAnyPublisher()
    }
}

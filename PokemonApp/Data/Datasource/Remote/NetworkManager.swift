//
//  NetworkManager.swift
//  PokemonApp
//
//  Created by Ibrohim Husain on 14/08/25.
//

import Alamofire
import RxSwift

protocol NetworkRequest {
    func fetchDecodable<T: Decodable>(_ endpoint: Endpoint, timeout: TimeInterval) -> Single<T>
}

final class NetworkManager: NetworkRequest {
    static let shared = NetworkManager()
    
    private init() {}
    
    func fetchDecodable<T: Decodable>(_ endpoint: Endpoint, timeout: TimeInterval = 60) -> Single<T> {
        Single.create { [weak self] single in
            guard let _ = self else { return Disposables.create() }
            let request = AF.request(
                endpoint.fullPath,
                method: endpoint.method,
                parameters: endpoint.parameter,
                headers: endpoint.header,
                requestModifier: { $0.timeoutInterval = timeout }
            )
                .validate()
                .responseDecodable(of: T.self) {
                    switch $0.result {
                    case .success(let data):
                        single(.success(data))
                    case .failure(let error):
                        single(.failure(error))
                    }
                }
            
            return Disposables.create { request.cancel() }
        }
    }
}

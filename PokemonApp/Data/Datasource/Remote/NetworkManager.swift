//
//  NetworkManager.swift
//  PokemonApp
//
//  Created by Ibrohim Husain on 14/08/25.
//

<<<<<<< HEAD
import Alamofire
import Combine
=======
import RxSwift
>>>>>>> cb547f2ce810f8bd02da633648b03148ea71b75f

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
    
<<<<<<< HEAD
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
=======
    func fetchDecodable<T: Decodable>(_ endpoint: Endpoint, timeout: TimeInterval = 60) -> Single<T> {
        Single.create { [weak self] single in
            guard let _ = self else { return Disposables.create() }
            
            guard var components = URLComponents(string: endpoint.fullPath) else {
                single(.failure(NetworkError.invalidURL))
                return Disposables.create()
            }
            
            if endpoint.method == .get, let params = endpoint.parameter {
                let items: [URLQueryItem] = params.map {
                    URLQueryItem(name: $0, value: String(describing: $1))
                }
                components.queryItems = (components.queryItems ?? []) + items
            }
            
            guard let url = components.url else {
                single(.failure(NetworkError.invalidURL))
                return Disposables.create()
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
                    single(.failure(NetworkError.requestBuildFailed))
                    return Disposables.create()
                }
            }
            
            let config = URLSessionConfiguration.default
            config.timeoutIntervalForRequest = timeout
            config.timeoutIntervalForResource = timeout
            let session = URLSession(configuration: config)
            
            let task = session.dataTask(with: request) {
                
                if let error = $2 {
                    single(.failure(error))
                    return
                }
                
                guard let http = $1 as? HTTPURLResponse else {
                    single(.failure(NetworkError.noHTTPResponse))
                    return
                }
                
                guard (200..<300).contains(http.statusCode) else {
                    single(.failure(NetworkError.server(status: http.statusCode, data: $0)))
                    return
                }
                
                guard let data = $0, !data.isEmpty else {
                    single(.failure(NetworkError.emptyData))
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let model = try decoder.decode(T.self, from: data)
                    single(.success(model))
                } catch {
                    single(.failure(error))
                }
            }
            
            task.resume()
            return Disposables.create { task.cancel() }
        }
>>>>>>> cb547f2ce810f8bd02da633648b03148ea71b75f
    }
}

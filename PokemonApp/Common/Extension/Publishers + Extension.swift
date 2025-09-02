//
//  Publishers + Extension.swift
//  PokemonApp
//
//  Created by Ibrohim Husain on 02/09/25.
//

import Combine

extension Publishers {
    struct Single<Output, Failure>: Publisher where Failure: Error {
        let promise: (@escaping (Result<Output, Failure>) -> Void) -> Void
        
        func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
            Deferred { Future(promise) }
            .subscribe(subscriber)
        }
    }
    
    struct ZipMany<Upstream: Publisher>: Publisher {
        typealias Output = [Upstream.Output]
        typealias Failure = Upstream.Failure
        
        private let publishers: [Upstream]
        
        init(_ publishers: [Upstream]) {
            self.publishers = publishers
        }
        
        func receive<S: Subscriber>(subscriber: S) where S.Input == Output, S.Failure == Failure {
            let initial = Just<Output>([])
                .setFailureType(to: Failure.self)
                .eraseToAnyPublisher()
            
            let zipped = publishers.reduce(into: initial) { result, publisher in
                result = result.zip(publisher) { elements, element in
                    elements + [element]
                }
                .eraseToAnyPublisher()
            }
            
            zipped.subscribe(subscriber)
        }
    }
}

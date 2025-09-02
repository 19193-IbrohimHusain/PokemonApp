//
//  UIGestureRecognizer + Extension.swift
//  PokemonApp
//
//  Created by Ibrohim Husain on 02/09/25.
//

import UIKit
import Combine

extension UIGestureRecognizer {
    struct GesturePublisher: Publisher {
        typealias Output = UIGestureRecognizer
        typealias Failure = Never

        private let gesture: UIGestureRecognizer
        init(_ gesture: UIGestureRecognizer) {
            self.gesture = gesture
        }

        func receive<S: Subscriber>(subscriber: S) where S.Input == Output, S.Failure == Failure {
            let sub = GestureSubscription(subscriber: subscriber, gesture: gesture)
            subscriber.receive(subscription: sub)
        }

        private final class GestureSubscription<S: Subscriber>: Subscription where S.Input == UIGestureRecognizer {
            private var subscriber: S?
            weak private var gesture: UIGestureRecognizer?

            init(subscriber: S, gesture: UIGestureRecognizer) {
                self.subscriber = subscriber
                self.gesture = gesture
                gesture.addTarget(self, action: #selector(handle))
            }

            func request(_ demand: Subscribers.Demand) {}

            func cancel() {
                gesture?.removeTarget(self, action: #selector(handle))
                subscriber = nil
            }

            @objc
            private func handle() {
                guard let gesture = gesture else { return }
                _ = subscriber?.receive(gesture)
            }
        }
    }

    var publisher: GesturePublisher {
        GesturePublisher(self)
    }
}

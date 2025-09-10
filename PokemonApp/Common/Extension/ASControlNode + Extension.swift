//
//  ASControlNode + Extension.swift
//  PokemonApp
//
//  Created by Ibrohim Husain on 10/09/25.
//

import AsyncDisplayKit
import Combine

extension ASControlNode {
    struct EventPublisher: Publisher {
        public typealias Output = Void
        public typealias Failure = Never

        private let control: ASControlNode
        private let events: ASControlNodeEvent

        init(control: ASControlNode, events: ASControlNodeEvent) {
            self.control = control
            self.events = events
        }

        public func receive<S: Subscriber>(subscriber: S) where Failure == S.Failure, Output == S.Input {
            let subscription = EventSubscription(
                subscriber: subscriber,
                control: control,
                event: events
            )
            subscriber.receive(subscription: subscription)
        }

        private final class EventSubscription<S: Subscriber>: Subscription where S.Input == Void {
            private var subscriber: S?
            weak private var control: ASControlNode?
            private let event: ASControlNodeEvent

            init(subscriber: S, control: ASControlNode, event: ASControlNodeEvent) {
                self.subscriber = subscriber
                self.control = control
                self.event = event
                control.addTarget(self, action: #selector(eventHandler), forControlEvents: event)
            }

            func request(_ demand: Subscribers.Demand) {}

            func cancel() {
                control?.removeTarget(self, action: #selector(eventHandler), forControlEvents: event)
                subscriber = nil
            }

            @objc
            private func eventHandler() {
                _ = subscriber?.receive(())
            }
        }
    }

    /// Combine-style publisher for control events
    func publisher(for events: ASControlNodeEvent) -> EventPublisher {
        EventPublisher(control: self, events: events)
    }
}

//
//  UIControl + Extension.swift
//  PokemonApp
//
//  Created by Ibrohim Husain on 02/09/25.
//

import Combine
import UIKit

extension UIControl {
    struct EventPublisher: Publisher {
        public typealias Output = Void
        public typealias Failure = Never

        private let control: UIControl
        private let events: UIControl.Event

        init(control: UIControl, events: UIControl.Event) {
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
            weak private var control: UIControl?
            private let event: UIControl.Event

            init(subscriber: S, control: UIControl, event: UIControl.Event) {
                self.subscriber = subscriber
                self.control = control
                self.event = event
                control.addTarget(self, action: #selector(eventHandler), for: event)
            }

            func request(_ demand: Subscribers.Demand) {}

            func cancel() {
                control?.removeTarget(self, action: #selector(eventHandler), for: event)
                subscriber = nil
            }

            @objc
            private func eventHandler() {
                _ = subscriber?.receive(())
            }
        }
    }

    /// Combine-style publisher for control events
    func publisher(for events: UIControl.Event) -> EventPublisher {
        EventPublisher(control: self, events: events)
    }
}

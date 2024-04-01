//
//  AnyPublisher+Create.swift
//  Core
//
//  Created by Julia Grasevych on 29.03.2024.
//

import Foundation
import Combine

public extension AnyPublisher {
    static func create<O, F>(work: @escaping (AnySubscriber<O, F>) -> AnyCancellable) -> AnyPublisher<O, F> where F: Error {
        let subject = PassthroughSubject<O, F>()
        var cancellable: AnyCancellable?
        
        return subject
            .handleEvents(
                receiveSubscription: { subscription in
                    let subscriber = AnySubscriber<O, F>(
                        receiveSubscription: { _ in },
                        receiveValue: { input in
                            subject.send(input)
                            return .unlimited
                        },
                        receiveCompletion: { completion in
                            subject.send(completion: completion)
                        }
                    )
                    cancellable = work(subscriber)
                },
                receiveCancel: {
                    cancellable?.cancel()
                }
            )
            .eraseToAnyPublisher()
    }
}

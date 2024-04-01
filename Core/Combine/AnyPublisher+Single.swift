//
//  AnyPublisher+Single.swift
//  Core
//
//  Created by Julia Grasevych on 27.03.2024.
//

import Foundation
import Combine

public extension AnyPublisher {
    static func single<O, F>(work: @escaping (@escaping Future<O, F>.Promise) -> ()) -> AnyPublisher<O, F> where F: Error {
        Deferred {
            Future { promise in
                work(promise)
            }
        }
        .eraseToAnyPublisher()
    }
}

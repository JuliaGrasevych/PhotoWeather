//
//  NestedObservedObjectContainer.swift
//  Core
//
//  Created by Julia Grasevych on 04.03.2024.
//

import Foundation
import Combine

/// Protocol to define input and output observed objects and subscribe to their changes
public protocol NestedObservedObjectContainer<Input, Output>: AnyObject {
    associatedtype Input: ObservableObject where Input.ObjectWillChangePublisher == ObservableObjectPublisher
    associatedtype Output: ObservableObject where Output.ObjectWillChangePublisher == ObservableObjectPublisher
    
    var input: Input { get }
    var output: Output { get }
    var nestedObservedObjectsSubscription: [AnyCancellable] { get set }
}

public extension NestedObservedObjectContainer where Self: ObservableObject, Self.ObjectWillChangePublisher == ObservableObjectPublisher {
    func subscribeNestedObservedObjects() {
        nestedObservedObjectsSubscription = []
        nestedObservedObjectsSubscription = [
            output.objectWillChange
                .sink { [weak self] _ in
                    self?.objectWillChange.send()
                },
            input.objectWillChange
                .sink { [weak self] _ in
                    self?.objectWillChange.send()
                }
        ]
    }
}

/// Empty subclass of ObservableObject
public class EmptyObservableObject: ObservableObject { }

/// Protocol with output observed object and void input
public protocol NestedObservedObjectOutputContainer: NestedObservedObjectContainer where Input == EmptyObservableObject {
}

public extension NestedObservedObjectOutputContainer {
    var input: Input { EmptyObservableObject() }
}


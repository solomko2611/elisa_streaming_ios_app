//
//  PublishedState.swift
//  ForaArchitecture
//
//  Created by Georgii Kazhuro on 14.07.2021.
//

import RxRelay
import RxSwift

@dynamicMemberLookup
class PublishedState<State> {
    private let initialState: State
    private let stateRelay: BehaviorRelay<State>
    fileprivate(set) var value: State {
        didSet {
            stateRelay.accept(value)
        }
    }
    
    fileprivate init(initialState: State) {
        self.initialState = initialState
        stateRelay = BehaviorRelay(value: initialState)
        value = initialState
    }
    
    func asObservable() -> Observable<State> {
        return stateRelay.asObservable()
    }
    
    func commit(changes: (inout State) -> ()) {
        var updatedState = stateRelay.value
        changes(&updatedState)
        value = updatedState
    }
    
    subscript<T>(dynamicMember keyPath: WritableKeyPath<State, T>) -> T {
        get { stateRelay.value[keyPath: keyPath] }
        set { value[keyPath: keyPath] = newValue }
    }
}

@propertyWrapper @dynamicMemberLookup
final class RxPublished<State> {
    private let publishedState: PublishedState<State>
    var wrappedValue: State {
        get {
            publishedState.value
        }
        set {
            publishedState.value = newValue
        }
    }
    
    init(wrappedValue: State) {
        self.publishedState = PublishedState<State>(initialState: wrappedValue)
        self.wrappedValue = wrappedValue
    }
    
    var projectedValue: PublishedState<State> {
        return publishedState
    }
    
    subscript<T>(dynamicMember keyPath: WritableKeyPath<State, T>) -> T {
        get { wrappedValue[keyPath: keyPath] }
        set { wrappedValue[keyPath: keyPath] = newValue }
    }
}

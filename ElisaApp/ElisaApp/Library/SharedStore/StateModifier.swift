//
//  StateModifier.swift
//  ForaArchitecture
//
//  Created by Georgii Kazhuro on 23.09.2021.
//

import RxSwift
import Foundation

class StateModifier<State> {
    private let disposeBag = DisposeBag()
    private let modifiedState = PublishSubject<State>()
    private let state = BehaviorSubject<State?>(value: nil)
    
    private init<Element>(modify: @escaping (Element, inout State) -> (), elementObservable: Observable<Element>) {
        Observable.combineLatest(state.compactMap { $0 }, elementObservable).take(1)
            .map { state, element -> State in
                var updatedState = state
                modify(element, &updatedState)
                return updatedState
            }.subscribe(onNext: { modifiedState in
                self.modifiedState.onNext(modifiedState)
            }).disposed(by: disposeBag)
    }
    
    private init(modify: @escaping (inout State) -> ()) {
        state.compactMap { $0 }.take(1)
            .map { state -> State in
                var updatedState = state
                modify(&updatedState)
                return updatedState
            }.subscribe(onNext: { modifiedState in
                self.modifiedState.onNext(modifiedState)
            }).disposed(by: disposeBag)
    }
    
    static func `async`<Element>(modify: @escaping (Element, inout State) -> (), elementObservable: Observable<Element>) -> StateModifier<State> {
        return StateModifier(modify: modify, elementObservable: elementObservable)
    }
    
    static func sync(modify: @escaping (inout State) -> ()) -> StateModifier<State> {
        return StateModifier(modify: modify)
    }
    
    func modifyState(state: Observable<State>) -> Observable<State> {
        state.subscribe(onNext: { [weak self] state in
            DispatchQueue.main.async {
                self?.state.onNext(state)
            }
        }).disposed(by: disposeBag)
        
        return modifiedState.take(1).asObservable()
    }
}

extension Observable {
    func stateModifier<State>(
        modify: @escaping (Element, inout State) -> ()
    ) -> StateModifier<State> {
        return .async(modify: modify, elementObservable: self)
    }
}

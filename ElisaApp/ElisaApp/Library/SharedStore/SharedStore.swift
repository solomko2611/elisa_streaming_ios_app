//
//  SharedStore.swift
//  ForaArchitecture
//
//  Created by Georgii Kazhuro on 23.09.2021.
//

import RxSwift
import RxRelay
import Foundation

class SharedStore<State, Event> {
    let disposeBag = DisposeBag()
    let events = PublishSubject<Event>()
    let state: BehaviorRelay<State>
    
    init(initialState: State, eventsHandler: EventsHandler<Event, State>) {
        self.state = BehaviorRelay(value: initialState)
        
        events.subscribe(onNext: { [weak self] event in
            guard let self = self else { return }
            self.handleEvent(event: event, eventsHandler: eventsHandler)
        }).disposed(by: disposeBag)
    }
    
    private func handleEvent(event: Event, eventsHandler: EventsHandler<Event, State>) {
        let stateModifier = eventsHandler.handleEvent(event)
        stateModifier?.modifyState(state: state.asObservable()).subscribe(onNext: { [weak self] modifiedState in
            self?.state.accept(modifiedState)
        }).disposed(by: disposeBag)
    }
    
    func scope<LocalState, LocalEvent>(
        state toLocalState: @escaping (State) -> LocalState,
        action fromLocalEvent: @escaping (LocalEvent) -> Event
    ) -> SharedStore<LocalState, LocalEvent> {
        let store = SharedStore<LocalState, LocalEvent>(
            initialState: toLocalState(self.state.value),
            eventsHandler: .init { event in
                self.events.onNext(fromLocalEvent(event))
                return nil
            }
        )
        
        state.subscribe(onNext: { localState in
            store.state.accept(toLocalState(localState))
        }).disposed(by: disposeBag)
        
        return store
    }
    
    public var actionless: SharedStore<State, Never> {
        func absurd<A>(_ never: Never) -> A {}
        return self.scope(state: { $0 }, action: absurd)
    }
}

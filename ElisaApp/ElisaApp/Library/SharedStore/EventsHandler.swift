//
//  EventsHandler.swift
//  ForaArchitecture
//
//  Created by Georgii Kazhuro on 23.09.2021.
//

class EventsHandler<Event, State> {
    private let run: (Event) -> StateModifier<State>?
    
    init(_ run: @escaping (Event) -> StateModifier<State>?) {
        self.run = run
    }
    
    func handleEvent(_ event: Event) -> StateModifier<State>? {
        return run(event)
    }
}

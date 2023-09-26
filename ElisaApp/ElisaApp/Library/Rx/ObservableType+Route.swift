//
//  ObservableType+Route.swift
//  ForaArchitecture
//
//  Created by Georgii Kazhuro on 14.07.2021.
//

import RxSwift

extension ObservableType {
    func route(startWith first: Element, when condition: @escaping (Element, Element) -> (Bool)) -> Observable<Element> {
        return withPrevious(startWith: first).filter(condition).map { $0.1 }
    }
}

//
//  ObservableType+WithPrevious.swift
//  ForaArchitecture
//
//  Created by Georgii Kazhuro on 14.07.2021.
//

import RxSwift

extension ObservableType {
    func withPrevious(startWith first: Element) -> Observable<(Element, Element)> {
        return scan((first, first)) { ($0.1, $1) }.skip(1)
    }
}

//
//  ViewModel.swift
//  ForaArchitecture
//
//  Created by Georgii Kazhuro on 14.07.2021.
//

import RxSwift

protocol ViewModel {
    var isVisible: BehaviorSubject<Bool> { get }
}

extension ViewModel {
    func whenVisible<T: ObservableType>(state: T) -> Observable<T.Element> {
        isVisible.filter { $0 }.flatMap { _ in state }
    }
}

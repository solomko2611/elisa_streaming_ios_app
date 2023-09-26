//
//  UpdatableStruct.swift
//  ElisaApp
//
//  Created by Dmitriy.K on 04.03.2022.
//

import RxRelay
import RxSwift

protocol UpdatableStruct {
    func setup<T>(_ keyPath: WritableKeyPath<Self, T>, to value: T) -> Self
}

extension UpdatableStruct {
    func setup<T>(_ keyPath: WritableKeyPath<Self, T>, to value: T) -> Self {
        var updatedValue = self
        updatedValue[keyPath: keyPath] = value
        return updatedValue
    }
}

extension BehaviorRelay where Element: UpdatableStruct {
    func update<T>(_ keyPath: WritableKeyPath<Element, T>, to newValue: T) {
        self.accept(value.setup(keyPath, to: newValue))
    }
}

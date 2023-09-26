//
//  Reactive+UIControlExtension.swift
//  ElisaApp
//
//  Created by alexandr galkin on 13.10.2022.
//

import RxSwift
import UIKit
import RxCocoa

extension Reactive where Base: UIControl {
    
    /// Reactive wrapper for `TouchUpInside` control event.
    public var tap: ControlEvent<Void> {
        controlEvent(.touchUpInside)
    }
}

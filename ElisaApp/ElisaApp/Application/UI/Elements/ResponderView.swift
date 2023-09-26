//
//  ResponderView.swift
//  ElisaApp
//
//  Created by Mikhail Sein on 30.03.2022.
//

import UIKit
import RxSwift

final class ResponderView: UIView {
    
    let onTouchEvent = PublishSubject<Void?>()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if frame.contains(point) {
            onTouchEvent.onNext(nil)
        }
        return false
    }
}

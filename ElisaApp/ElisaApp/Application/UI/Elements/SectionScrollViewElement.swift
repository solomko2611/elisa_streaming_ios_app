//
//  SectionScrollViewElement.swift
//  ElisaApp
//
//  Created by alexandr galkin on 10.08.2022.
//

import Foundation
import UIKit

protocol SectionScrollViewElementDelegate: AnyObject {
    func wasTapped(index: Int)
}

final class SectionScrollViewElement: UIControl {
    enum State {
        case selected, unselected
    }
    
    weak var delegate: SectionScrollViewElementDelegate?
    
    private let generator = UIImpactFeedbackGenerator(style: .light)
    
    private(set) var isHighlightedNew: Bool = false
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.font = .poppinsFont(ofSize: 17, font: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        addTarget(self, action: #selector(tapHandler), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(state: SectionScrollViewElement.State) {
        switch state {
        case .selected:
            label.textColor = .black
            isHighlighted = true
        case .unselected:
            label.textColor = .gray4
            isHighlighted = false

        }
    }
    
    func configure(text: String, index: Int) {
        label.text = text
        self.tag = index
    }
    
    private func configureView() {
        addSubview(label)
        label.addConstraints(to: self)
    }
    
    @objc private func tapHandler() {
        generator.impactOccurred()
        delegate?.wasTapped(index: tag)
    }
    
}

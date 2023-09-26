//
//  PageListHeader.swift
//  ElisaApp
//
//  Created by Mikhail Sein on 16.03.2022.
//

import UIKit

class PageListHeader: UITableViewHeaderFooterView {
    
    enum State: Hashable {
        case page(Page)
    }
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.configure(textColor: .black, font: .poppinsFont(ofSize: 20, font: .semibold))
        return label
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        configureView()
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureView() {
        addSubviews(titleLabel)
    }
    
    private func configureConstraints() {
        titleLabel.addConstraints(top: topAnchor, leading: leadingAnchor, trailing: trailingAnchor, bottom: bottomAnchor, leadingPadding: 18)
    }
    
    func configureView(with state: State) {
        switch state {
        case .page(let page):
            titleLabel.text = page.name
        }
    }
}

//
//  PageListEmptyCell.swift
//  ElisaApp
//
//  Created by Mikhail Sein on 17.03.2022.
//

import UIKit

final class PageListEmptyCell: UITableViewCell {
    
    struct State: Hashable {
        let text: String
    }
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.configure(textColor: .gray3, font: .poppinsFont(ofSize: 17, font: .regular))
        return label
    }()
    
    // MARK: - Initializer
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configureCell()
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Methods
    
    private func configureCell() {
        backgroundColor = .clear
        selectionStyle = .none
    }
    
    private func configureConstraints() {
        contentView.addSubviews(titleLabel)
        
        titleLabel.addConstraints(top: contentView.topAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, bottom: contentView.bottomAnchor, leadingPadding: 18, height: 42)
    }
    
    // MARK: - Public Methods

    func configureCell(with state: State) {
        titleLabel.text = state.text
    }
}

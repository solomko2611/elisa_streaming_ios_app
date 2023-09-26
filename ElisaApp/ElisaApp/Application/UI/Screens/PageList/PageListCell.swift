//
//  PageListCell.swift
//  ElisaApp
//
//  Created by Dmitriy.K on 10.03.2022.
//

import UIKit

final class PageListCell: UITableViewCell {
    
    enum State: Hashable {
        case campaign(Campaign)
    }
    
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        return stackView
    }()
    
    private lazy var campaignNameLabel: UILabel = {
        let label = UILabel()
        label.configure(textColor: .black, font: .poppinsFont(ofSize: 17, font: .semibold))
        return label
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.configure(textColor: .gray1, font: .poppinsFont(ofSize: 17, font: .regular))
        label.isHidden = true
        return label
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray5
        return view
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
        selectionStyle = .none
        backgroundColor = .white
        contentView.addSubviews(containerView)
        contentStackView.addArrangedSubviews(campaignNameLabel, dateLabel)
        containerView.addSubviews(contentStackView)
        
        containerView.layer.cornerRadius = 12
        containerView.clipsToBounds = false
    }
    
    private func configureConstraints() {
        containerView.addConstraints(top: contentView.topAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, bottom: contentView.bottomAnchor, topPadding: 6, leadingPadding: 17, trailingPadding: 17, bottomPadding: 6, height: 84)
        contentStackView.addConstraints(top: containerView.topAnchor, leading: containerView.leadingAnchor, trailing: containerView.trailingAnchor, bottom: containerView.bottomAnchor, topPadding: 16, leadingPadding: 16, trailingPadding: 16, bottomPadding: 16)
    }
    
    // MARK: - Public Methods

    func configureCell(with state: State) {
        switch state {
        case .campaign(let model):
            if let startTime = model.startTime {
                dateLabel.isHidden = false
                let date = Date(timeIntervalSince1970ms: Double(startTime))
                let formatter = DateFormatter()
                let timeFormat = "yyyy"
                formatter.dateFormat = timeFormat
                let dayMonthString = date.string(with: .details)
                dateLabel.text = "\(formatter.string(from: date)), \(dayMonthString)"
            } else {
                dateLabel.isHidden = true
            }
            campaignNameLabel.text = model.name
        }
    }
}

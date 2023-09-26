//
//  PageListSection.swift
//  ElisaApp
//
//  Created by Dmitriy.K on 11.03.2022.
//

import Foundation

enum PageListSection: Hashable {
    case page(PageListHeader.State)
}

enum PageListSectionItem: Hashable {
    case campaign(PageListCell.State)
    case empty(PageListEmptyCell.State)
}

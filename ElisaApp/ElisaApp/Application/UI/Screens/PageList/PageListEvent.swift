//
//  StreamListEvent.swift
//  ElisaApp
//
//  Created by Dmitriy.K on 05.03.2022.
//

import Foundation

enum PageListEvent {
    case getPages(IndexPath?)
    case campaignSelected(Campaign, Page)
    case logoutPressed
    case scrollViewSectionWasTapped(Int)
}

struct PageListInput {
    let loading: Bool
    let pages: [Page]
    let sectionsName: [String]
    let currentSelectedScrollSection: Int
    let needsToReloadScrollView: Bool
    let shouldScrollTableTo: IndexPath?
}


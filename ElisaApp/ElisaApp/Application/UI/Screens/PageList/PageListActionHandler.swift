//
//  StreamListActionHandler.swift
//  ElisaApp
//
//  Created by Dmitry Karpinsky on 08.03.2022.
//

import Foundation

enum PageListViewModelActions {
    case showStream(Campaign, Page)
    case logout(completion: () -> Void)
}


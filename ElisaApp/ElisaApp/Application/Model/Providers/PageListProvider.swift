//
//  StreamListProvider.swift
//  ElisaApp
//
//  Created by Dmitriy.K on 05.03.2022.
//

import Foundation
import RxSwift
import RxRelay
import SwiftLazy
import CoreText
import UIKit

protocol PageListProvider {
    var state: BehaviorRelay<PageListProviderState> { get }
    
    func getPages(lastVisibleCell: IndexPath?)
    func selectScrollSection(index: Int)
}

struct PageListProviderState: UpdatableStruct {
    var loading = true
    var pages: [Page] = []
    var sectionsName: [String] = []
    var currentSelectedScrollSection: Int = 0
    var campainsDataChanges: Bool = false
    var shouldScrollTo: IndexPath?
}

class PageListProviderImpl {
    
    // MARK: - Public Properties
    
    let state: BehaviorRelay<PageListProviderState>
    
    // MARK: - Private Properties
    
    private let collectionService: Lazy<CollectionService>
  
    private let disposeBag = DisposeBag()
    
    // MARK: - Initializer
    
    init(collectionService: Lazy<CollectionService>) {
        self.collectionService = collectionService
        self.state = BehaviorRelay<PageListProviderState>(value: PageListProviderState())
        NotificationCenter.default.rx.notification(UIApplication.didBecomeActiveNotification).subscribe(onNext: { [weak self] _ in
            self?.getPages(lastVisibleCell: nil)
        }).disposed(by: disposeBag)
    }
}

extension PageListProviderImpl: PageListProvider {
    func getPages(lastVisibleCell: IndexPath?) {
        state.update(\.loading, to: true)
        collectionService.value.getPages { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                let currentPages = self.state.value.pages
                let newPages = data.items.compactMap{ $0.name }
                if currentPages != data.items {
                    self.state.update(\.currentSelectedScrollSection, to: 0)
                    self.state.update(\.pages, to: data.items)
                    self.state.update(\.sectionsName, to: newPages)
                    self.state.update(\.shouldScrollTo, to: lastVisibleCell)
                    self.state.update(\.campainsDataChanges, to: true)
                    self.state.update(\.campainsDataChanges, to: false)
                    self.state.update(\.shouldScrollTo, to: nil)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
            self.state.update(\.loading, to: false)
        }
    }
    
    func selectScrollSection(index: Int) {
        state.update(\.currentSelectedScrollSection, to: index)
    }
}

//
//  StreamListViewModel.swift
//  ElisaApp
//
//  Created by Dmitriy.K on 05.03.2022.
//

import Foundation
import RxSwift


protocol PageListViewModel: AnyObject {
    var input: Observable<PageListInput> { get }
    var events: PublishSubject<PageListEvent> { get }
    var actionHandler: ((PageListViewModelActions) -> Void)? { get set }
}

class PageListViewModelImpl: PageListViewModel {

    // MARK: - Public Properties
    
    let input: Observable<PageListInput>
    let events = PublishSubject<PageListEvent>()
    var actionHandler: ((PageListViewModelActions) -> Void)?

    // MARK: - Private Properties
    
    private let pageListProvider: PageListProvider
    private let authProvider: AuthProvider
    private let disposeBag = DisposeBag()

    // MARK: - Initializer
    
    init(pageListProvider: PageListProvider, authProvider: AuthProvider) {
        self.pageListProvider = pageListProvider
        self.authProvider = authProvider
        
        input = pageListProvider.state.map({
            PageListInput(
                loading: $0.loading,
                pages: $0.pages,
                sectionsName: $0.sectionsName,
                currentSelectedScrollSection: $0.currentSelectedScrollSection,
                needsToReloadScrollView: $0.campainsDataChanges,
                shouldScrollTableTo: $0.shouldScrollTo
            )
        })
        
        events.subscribe(onNext: { [weak self] event in
            self?.processEvent(event: event)
        }).disposed(by: disposeBag)
    }
    
    // MARK: - Private Methods
    
    private func processEvent(event: PageListEvent) {
        switch event {
        case .getPages(let indexPath):
            pageListProvider.getPages(lastVisibleCell: indexPath)
        case .campaignSelected(let campaign, let page):
            actionHandler?(.showStream(campaign, page))
        case .logoutPressed:
            actionHandler?(.logout(completion: authProvider.logout))
        case .scrollViewSectionWasTapped(let index):
            pageListProvider.selectScrollSection(index: index)

        }
    }
}

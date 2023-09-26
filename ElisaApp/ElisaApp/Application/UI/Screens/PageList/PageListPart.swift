//
//  StreamListPart.swift
//  ElisaApp
//
//  Created by Dmitriy.K on 05.03.2022.
//

import DITranquillity

final class PageListPart: DIPart {
   
    static func load(container: DIContainer) {
        container.register(PageListViewModelImpl.init).as(PageListViewModel.self).lifetime(.objectGraph)
        container.register(PageListProviderImpl.init).as(PageListProvider.self).lifetime(.objectGraph)
        container.register(PageListViewController.init(viewModel:)).lifetime(.objectGraph)
        container.register(PageListDependency.init(viewModel:viewController:)).lifetime(.prototype)
    }
}

struct PageListDependency {
    var viewModel: PageListViewModel
    let viewController: PageListViewController
}

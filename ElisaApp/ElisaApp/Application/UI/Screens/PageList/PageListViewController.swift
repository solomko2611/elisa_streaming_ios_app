//
//  StreamListViewController.swift
//  ElisaApp
//
//  Created by Dmitriy.K on 05.03.2022.
//

import UIKit
import RxSwift
import DiffableDataSources

struct PageListViewInput {
    let campaignName: String
}

class PageListViewController: BaseViewController {
    
    enum ScrollDirection {
        case up, down
    }
    
    // MARK: - Private Properties
    
    private let viewModel: PageListViewModel
    private var disposeBag = DisposeBag()
    private var pages: [PageListViewInput] = []
    private var sectionsNameButtons: [SectionScrollViewElement] = []
    private var sectionsNameButtonsFrame = CGRect.zero
    private var lastScrollDirection: ScrollDirection?
    private var lastContentOffset: CGFloat = 0.0
    private var scrollByTap = false
    private var scrollViewTrailingAnchor: NSLayoutConstraint!
    private var tableViewScrollTopConstraint: NSLayoutConstraint!
    private var tableViewTopConstraint: NSLayoutConstraint!

    private var isLoading = false
    
    private lazy var contentScrollView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true
        return view
    }()

    private lazy var logoutButton: UIButton = {
        let button = UIButton()
        button.configure(title: "Log out",
                         titleColor: UIColor.black,
                         font: UIFont.poppinsFont(ofSize: 17, font: .regular),
                         backgroundColor: UIColor.white,
                         cornerRadius: 19)
        button.layer.borderWidth = 1.0
        button.layer.borderColor = UIColor.gray6.cgColor
        return button
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.delegate = self
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.allowsSelection = true
        return tableView
    }()
    
    private lazy var sectionsScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl()
        refresh.layer.zPosition = -1
        refresh.tintColor = .gray3
        let string = "Pull to refresh"
        let attributedString = NSMutableAttributedString(string: string, attributes: [
            .foregroundColor: UIColor.gray3,
            .font: UIFont.poppinsFont(ofSize: 13, font: .regular)
        ])
        let range = (string as NSString).range(of: "refresh")
        attributedString.addAttribute(.font, value: UIFont.poppinsFont(ofSize: 13, font: .semibold), range: range)
        refresh.attributedTitle = attributedString
        return refresh
    }()
    
    private var dataSource: TableViewDiffableDataSource<PageListSection, PageListSectionItem>?
    
    private lazy var emptyDataView: EmptyDataView = {
        let view = EmptyDataView()
        view.configureView(with: .init(title: "No campaigns yet", subtitle: "Create first campaign and boost your live shopping"))
        view.isHidden = true
        return view
    }()
    
    // MARK: - Initializer
    
    init(viewModel: PageListViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        
        self.isLoginFlow = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - ViewController Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureConstraints()
        configureObservable()
        registerCells()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getPages()
    }
    
    override func viewWillLayoutSubviews() {
        sectionsScrollView.contentSize.height = 1.0
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.refreshControl = refreshControl

        if contentScrollView.bounds.width <= view.bounds.width - 18 {
            sectionsScrollView.contentInset = UIEdgeInsets(top: 0,
                                                           left: 18,
                                                           bottom: 0,
                                                           right: contentScrollView.bounds.width - 1)
            
        } else {
            sectionsScrollView.contentInset = UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18)
        }
    }
    
    
    // MARK: - Private Methods
    
    private func configureView() {
        view.backgroundColor = .white
        navigationController?.setNavigationBarHidden(true, animated: false)
        view.addSubviews(logoutButton, tableView, emptyDataView, sectionsScrollView)
        sectionsScrollView.addSubview(contentScrollView)
        tableView.dataSource = createTableDataSource()
    }
    
    private func configureConstraints() {
        tableViewTopConstraint = tableView.topAnchor.constraint(equalTo: logoImage.bottomAnchor, constant: 48)
        tableViewScrollTopConstraint = tableView.topAnchor.constraint(equalTo: sectionsScrollView.bottomAnchor, constant: 15)
        logoutButton.addConstraints(top: topLine.bottomAnchor, trailing: view.safeAreaLayoutGuide.trailingAnchor, topPadding: 19, trailingPadding: 32, width: 95, height: 38)
        tableView.addConstraints(leading: view.leadingAnchor, trailing: view.trailingAnchor, bottom: view.bottomAnchor, topPadding: 15, bottomPadding: 32)
        emptyDataView.addConstraints(widthAnchor: view.widthAnchor, widthAnchorMultiplier: 0.7, centerX: view, centerY: view)
        sectionsScrollView.addConstraints(top: logoImage.bottomAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor, topPadding: 48, height: 26)
    }
    
    private func createTableDataSource() -> TableViewDiffableDataSource<PageListSection, PageListSectionItem>? {
        dataSource = TableViewDiffableDataSource<PageListSection, PageListSectionItem>(tableView: tableView) { tableView, indexPath, item in
            switch item {
            case .campaign(let state):
                let cell: PageListCell = tableView.dequeueReusableCell(for: indexPath)
                cell.configureCell(with: state)
                return cell
            case .empty(let state):
                let cell: PageListEmptyCell = tableView.dequeueReusableCell(for: indexPath)
                cell.configureCell(with: state)
                return cell
            }
        }
        return dataSource
    }
    
    private func configureObservable() {
        viewModel.input.observe(on: MainScheduler.asyncInstance).subscribe(onNext: { [weak self] data in
            self?.render(data: data)
        }).disposed(by: disposeBag)
        
        logoutButton.rx.tap.subscribe(onNext: { [weak self] in
            self?.viewModel.events.onNext(.logoutPressed)
        }).disposed(by: disposeBag)
        
        tableView.rx.itemSelected.subscribe(onNext: { [weak self] indexPath in
            if case .campaign(let campaignState) = self?.dataSource?.itemIdentifier(for: indexPath),
               case .campaign(let campaign) = campaignState,
               case .page(let sectionState) = self?.dataSource?.snapshot().sectionIdentifiers[indexPath.section],
               case .page(let page) = sectionState
            {
                self?.viewModel.events.onNext(.campaignSelected(campaign, page))
            }
        }).disposed(by: disposeBag)
        
        refreshControl.rx.controlEvent(.valueChanged).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            print("RX refreshing")
            if !self.isLoading {
                self.getPages()
            }
        }).disposed(by: disposeBag)
    }
    
    private func getPages() {
        var lastVisibleCellIndexPath: IndexPath?
        if let last = tableView.visibleCells.last {
            lastVisibleCellIndexPath = tableView.indexPath(for: last)
        }
        
        viewModel.events.onNext(.getPages(lastVisibleCellIndexPath))
    }
    
    private func registerCells() {
        tableView.register(PageListCell.self, PageListEmptyCell.self)
        tableView.register(PageListHeader.self, forHeaderFooterViewReuseIdentifier: "PageListHeader")
    }
    
    private func render(data: PageListInput) {
        emptyDataView.isHidden = !data.pages.isEmpty || data.loading
        isLoading = data.loading
        if !data.loading && refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
        
        guard !data.pages.isEmpty else { return }
        
        var snapshot = DiffableDataSourceSnapshot<PageListSection, PageListSectionItem>()
        
        data.pages.forEach { page in
            let section: PageListSection = .page(.page(page))
            snapshot.appendSections([section])
            if let campaigns = page.campaigns {
                snapshot.appendItems(campaigns.items.map { .campaign(.campaign($0))}, toSection: section)
            } else {
                snapshot.appendItems([.empty(.init(text: "No campaigns for this page"))], toSection: section)
            }
        }
        dataSource?.defaultRowAnimation = .fade
        dataSource?.apply(snapshot, animatingDifferences: true)
        
        if let numberOfSections = dataSource?.snapshot().numberOfSections,
           numberOfSections != 0 && !sectionsNameButtons.isEmpty && !refreshControl.isRefreshing {
            scrollByTap = true
            tableView.scrollToRow(at: IndexPath(row: 0, section: data.currentSelectedScrollSection), at: .top, animated: true)

            moveScrollView(to: data.currentSelectedScrollSection)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.scrollByTap = false
            }
        }
        
        if let indexPath = data.shouldScrollTableTo {
            tableView.scrollToRow(at: indexPath, at: .none, animated: false)
        }
        
        if data.needsToReloadScrollView {
            if data.sectionsName.count > 1 {
                sectionsScrollView.isHidden = false
                fillScrollView(sections: data.sectionsName)
                tableViewTopConstraint.isActive = false
                tableViewScrollTopConstraint.isActive = true
            } else {
                tableViewScrollTopConstraint.isActive = false
                tableViewTopConstraint.isActive = true
                sectionsScrollView.isHidden = true
            }
        }
    }
    
    private func fillScrollView(sections: [String]) {
        sectionsNameButtons.forEach { $0.removeFromSuperview() }
        contentScrollView.removeFromSuperview()
        sectionsScrollView.addSubview(contentScrollView)
        sectionsNameButtons.removeAll()
        contentScrollView.addConstraints(top: sectionsScrollView.contentLayoutGuide.topAnchor,
                                  leading: sectionsScrollView.contentLayoutGuide.leadingAnchor,
                                  trailing: sectionsScrollView.contentLayoutGuide.trailingAnchor,
                                  bottom: sectionsScrollView.contentLayoutGuide.bottomAnchor)
        
        sections.enumerated().forEach { index, name in
            let scrollButton = SectionScrollViewElement()
            scrollButton.configure(text: name, index: index)
            scrollButton.translatesAutoresizingMaskIntoConstraints = false
            scrollButton.delegate = self
            sectionsNameButtons.append(scrollButton)
            contentScrollView.addSubview(scrollButton)
        }
        
        for index in 0..<sectionsNameButtons.count {
            if index == 0 {
                sectionsNameButtons[index].addConstraints(top: contentScrollView.topAnchor,
                                                          leading: contentScrollView.leadingAnchor,
                                                          bottom: contentScrollView.bottomAnchor, bottomPadding: 2)
            }
            
            if index != 0 && index != sectionsNameButtons.count - 1 {
                sectionsNameButtons[index].addConstraints(top: contentScrollView.topAnchor,
                                                          leading: sectionsNameButtons[index - 1].trailingAnchor,
                                                          bottom: contentScrollView.bottomAnchor,
                                                          leadingPadding: 34, bottomPadding: 2)
            }
            
            if index == sectionsNameButtons.count - 1 && sectionsNameButtons.count != 1 {
                sectionsNameButtons[index].addConstraints(top: contentScrollView.topAnchor,
                                                          leading: sectionsNameButtons[index - 1].trailingAnchor,
                                                          trailing: contentScrollView.trailingAnchor,
                                                          bottom: contentScrollView.bottomAnchor,
                                                          leadingPadding: 34, bottomPadding: 2)
            }
        }
        
        sectionsScrollView.setNeedsLayout()
        sectionsScrollView.layoutIfNeeded()
    }
    
    private func moveScrollView(to section: Int) {
        let newOrigin = CGPoint(x: self.sectionsNameButtons[section].frame.origin.x - 18.0,
                                 y: self.sectionsNameButtons[section].frame.origin.y)
        
        UIView.animate(withDuration: 0.2, delay: 0.0) {
            self.sectionsScrollView.contentOffset = newOrigin
        }
        
        sectionsNameButtons.forEach {
            if $0.tag != section {
                $0.configure(state: .unselected)
            } else {
                $0.configure(state: .selected)
            }
        }
    }
}

extension PageListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let selectedSection = dataSource?.snapshot().sectionIdentifiers[section] else {return nil}
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "PageListHeader") as? PageListHeader
        
        switch selectedSection {
        case .page(let state):
            view?.configureView(with: state)
        }
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        40
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !scrollByTap else { return }
        
        if (self.lastContentOffset > scrollView.contentOffset.y) {
            lastScrollDirection = .up
        } else if (self.lastContentOffset < scrollView.contentOffset.y){
            lastScrollDirection = .down
        }

        lastContentOffset = scrollView.contentOffset.y
        
        if scrollView.contentOffset.y < 10 {
            if let visibleRows = tableView.indexPathsForVisibleRows {
                let visibleSections = visibleRows.map({$0.section})
                if visibleRows.count > 1, let first = visibleSections.first, !sectionsNameButtons.isEmpty {
                    sectionsNameButtons[first].configure(state: .selected)
                    moveScrollView(to: first)
                    return
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        
        guard let scrollDirection = lastScrollDirection, scrollDirection == .up, !scrollByTap else { return }
        
        if !sectionsNameButtons.isEmpty {
            if section == 0 {
                moveScrollView(to: section)
            } else {
                moveScrollView(to: section - 1)
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView(frame: .zero)
    }
    
    func tableView(_ tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int) {
        guard let scrollDirection = lastScrollDirection, scrollDirection == .down, !scrollByTap else { return }
        
        if !sectionsNameButtons.isEmpty {
            if section == sectionsNameButtons.count - 1 {
                moveScrollView(to: section)
            } else {
                moveScrollView(to: section + 1)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let scrollDirection = lastScrollDirection, scrollDirection == .up, !scrollByTap else { return }
        
        if !sectionsNameButtons.isEmpty {
            moveScrollView(to: section)
        }
    }

}

extension PageListViewController: SectionScrollViewElementDelegate {
    func wasTapped(index: Int) {
        viewModel.events.onNext(.scrollViewSectionWasTapped(index))
    }
}

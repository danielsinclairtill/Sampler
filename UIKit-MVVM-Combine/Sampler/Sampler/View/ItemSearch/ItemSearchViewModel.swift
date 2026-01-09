//
//  ItemSearchViewModel.swift
//  Sampler
//
//  Created by Daniel on 2026-01-09.
//

import Foundation
import Combine


// MARK: Input + Output
enum ItemSearchViewModelBinding {
    protocol Contract: SamplerViewModelContract where Input == ItemSearchViewModelBinding.Input,
                                                      Output == ItemSearchViewModelBinding.Output {
        var imageManager: ImageManagerContract { get }
    }
    
    class Input: ObservableObject {
        /// The view did load.
        var viewDidLoad = PassthroughSubject<Void, Never>()
        /// The items list is in the loading state and ready to refresh the data.
        var refresh = PassthroughSubject<Void, Never>()
        /// The user performs an action which intends to refresh the items list.
        var refreshBegin = PassthroughSubject<Void, Never>()
        /// The next page of items in the list should load.
        var loadNextPage = PassthroughSubject<Void, Never>()
        /// The items list is currently scrolling automatically.
        @Published var isScrolling: Bool = false
        /// The user is at the top of the items list.
        @Published var isTopOfPage: Bool = true
        /// A cell at a row index was tapped in the items list.
        var cellTapped = PassthroughSubject<Int, Never>()
        /// The text in the search bar.
        @Published var searchText: String = ""
    }

    class Output: ObservableObject {
        /// The items list to display.
        @Published var items: [Item] = []
        /// Show the items list in a refreshing state.
        @Published var isRefreshing: Bool = false
        /// Show an error message to display over the items list.
        @Published var error: String = ""
        /// Scroll the items list to the top automatically.
        fileprivate(set) var scrollToTop = PassthroughSubject<Void, Never>()
        /// The total number of items possible in the list.
        @Published var total: Int = 0
        /// If the items list are loading by refreshing or pagnation.
        @Published fileprivate var isLoading: Bool = false
        
        init(items: [Item] = [],
             isRefreshing: Bool = false,
             error: String = "",
             scrollToTop: PassthroughSubject<Void, Never> = PassthroughSubject<Void, Never>(),
             total: Int = 0,
             isLoading: Bool = false) {
            self.items = items
            self.isRefreshing = isRefreshing
            self.error = error
            self.scrollToTop = scrollToTop
            self.total = total
            self.isLoading = isLoading
        }
    }
}

// MARK: ViewModel
class ItemSearchViewModel: ItemSearchViewModelBinding.Contract, ObservableObject {
    @Published var input = ItemSearchViewModelBinding.Input()
    @Published var output = ItemSearchViewModelBinding.Output()
    private let coordinator: ItemSearchCoordinator
    private var cancelBag = Set<AnyCancellable>()
    
    private let environment: EnvironmentContract
    var imageManager: ImageManagerContract {
        return environment.api.imageManager
    }
    
    init(environment: EnvironmentContract,
         coordinator: ItemSearchCoordinator) {
        self.environment = environment
        self.coordinator = coordinator
        
        // bind inputs and outputs
        setViewDidLoad()
        setRefresh()
        setLoadNextPage()
        setCellTapped()
        setTabBarItemTappedWhileDisplayed()
    }
    
    private func updateData(searchText: String,
                            offset: Int = 0) {
        if offset == 0 {
            output.isRefreshing = true
        }
        output.isLoading = true

        guard !searchText.isEmpty else {
            output.items = []
            output.isLoading = false
            output.isRefreshing = false
            return
        }
        
        environment.api.get(request: ItemRequest.Search(text: searchText, offset: offset)) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let data):
                guard !data.items.isEmpty else {
                    strongSelf.output.items = []
                    break
                }

                let newItems = data.items
                
                strongSelf.output.total = data.total
                // if an offset was passed it is a load next page call
                if offset > 0 && !strongSelf.output.items.isEmpty {
                    strongSelf.output.items.append(contentsOf: newItems)
                } else {
                    strongSelf.output.items = newItems
                }
                // prefetch the first 10 items images required for the cells
                strongSelf.prefetchImages(items: Array(newItems.prefix(10)))
            case .failure(let error):
                // keep whatever the previous state of the items list was, and send an error
                strongSelf.output.error = error.message
            }
            strongSelf.output.isLoading = false
            strongSelf.output.isRefreshing = false
        }
    }

    private func prefetchImages(items: [Item]) {
        let prefetchImageURLs = items.compactMap { $0.image }
        environment.api.imageManager.prefetchImages(prefetchImageURLs, reset: true)
    }
    
    // MARK: Binding
    
    private func setViewDidLoad() {
        input.viewDidLoad.sink { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.input.refreshBegin.send(())
        }
        .store(in: &cancelBag)
    }

    private func setRefresh() {
        input.$searchText
            .removeDuplicates()
            .debounce(for: 0.2,
                      scheduler: DispatchQueue.main)
            .sink { [weak self] searchText in
                guard let strongSelf = self else { return }
                guard !searchText.isEmpty else {
                    strongSelf.output.items = []
                    strongSelf.output.isLoading = false
                    strongSelf.output.isRefreshing = false
                    return
                }
                strongSelf.input.refreshBegin.send(())
            }
            .store(in: &cancelBag)
        
        input.refreshBegin
            .sink { [weak self] refreshType in
                guard let strongSelf = self else { return }
                strongSelf.output.isRefreshing = true
            }
            .store(in: &cancelBag)
        
        // all animations should be completed after refreshBegin and before starting the refresh
        input.refresh
            .sink { [weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.updateData(searchText: strongSelf.input.searchText)
            }
            .store(in: &cancelBag)
    }
    
    private func setLoadNextPage() {
        input.loadNextPage
            // ensure not to load anymore if the total number of items is already displayed
            .filter { [weak self] in
                guard let strongSelf = self else { return false }
                return !strongSelf.output.isLoading && strongSelf.output.items.count < strongSelf.output.total
            }
            .sink {  [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.updateData(searchText: strongSelf.input.searchText,
                                      offset: strongSelf.output.items.count)
            }
            .store(in: &cancelBag)
    }

    private func setCellTapped() {
        input.cellTapped.map { ($0, self.output.items) }
            .sink { [weak self] (row, items) in
                if items.indices.contains(row),
                   let id = items[row].id {
                    self?.coordinator.itemDetail(id: String(id))
                }
            }
            .store(in: &cancelBag)
    }
    
    private func setTabBarItemTappedWhileDisplayed() {
        coordinator.tabBarItemTappedWhileDisplayed.map { ($0, self.input.isTopOfPage, self.input.isScrolling) }
            .filter { _, isTopOfPage, isScrolling in !isTopOfPage && !isScrolling }
            .sink { [weak self] _, _, _ in
                self?.output.scrollToTop.send(())
            }
            .store(in: &cancelBag)
    }
}


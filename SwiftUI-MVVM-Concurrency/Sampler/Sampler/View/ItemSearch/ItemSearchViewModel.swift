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
    protocol Contract: SamplerViewModelContract where
    Output == ItemSearchViewModelBinding.Output { }
    
    protocol Input {
        /// The items list is in the loading state and ready to refresh the data.
        func refresh()
        /// The user performs an action which intends to refresh the items list.
        func refreshBegin()
        /// The next page of items in the list should load.
        func loadNextPage()
        /// A cell at a row index was tapped in the items list.
        func cellTapped(index: Int)
    }

    @Observable
    class Output {
        /// The text in the search bar.
        var searchText: String
        /// The items list to display.
        var items: [Item] = []
        /// Show the items list in a refreshing state.
        var isRefreshing: Bool = false
        /// Show an error message to display over the items list.
        var error: String?
        /// The total number of items possible in the list.
        var total: Int = 0
        /// If the items list are loading by refreshing or pagnation.
        fileprivate var isLoading: Bool = false
        /// If the list has more  items that should load.
        var hasMorePages: Bool = false
        
        init(searchText: String = "",
             items: [Item] = [],
             isRefreshing: Bool = false,
             error: String? = nil,
             total: Int = 0,
             isLoading: Bool = false) {
            self.searchText = ""
            self.items = items
            self.isRefreshing = isRefreshing
            self.error = error
            self.total = total
            self.isLoading = isLoading
        }
    }
}

// MARK: ViewModel
class ItemSearchViewModel: ItemSearchViewModelBinding.Contract,
                            ItemSearchViewModelBinding.Input {
    var output: Output
    typealias Environment = ItemRepositoryProvider &
                            ImageMangagerProvider
    private let environment: Environment
    private var router: ItemSearchRouter
    
    private lazy var searchDebounce = Debounce(for: .milliseconds(200)) { [weak self] text in
        await self?.searchText(text)
    }
    private var cancelBag = Set<AnyCancellable>()
    private var observeBag = ObserveBag()

    var imageManager: ImageManagerContract {
        environment.imageManager
    }

    init(output: ItemSearchViewModelBinding.Output = .init(),
         environment: Environment = SamplerEnvironment.shared,
         router: ItemSearchRouter) {
        self.output = output
        self.environment = environment
        self.router = router
        
        debounceSearchText()
    }
    
    private func updateData(searchText: String,
                            offset: Int = 0) {
        output.isLoading = true
        output.error = nil
        
        guard !searchText.isEmpty else {
            output.items = []
            output.isLoading = false
            output.isRefreshing = false
            return
        }
        
        Task { @MainActor [weak self] in
            guard let strongSelf = self else { return }
            do {
                let results = try await strongSelf.environment.itemRepository.searchItem(text: searchText,
                                                                                         offset: offset,
                                                                                         limit: 10)
                if results.data.items.isEmpty {
                    strongSelf.output.items = []
                } else {
                    let newItems = results.data.items
                    
                    strongSelf.output.total = results.data.total
                    // if an offset was passed it is a load next page call
                    if offset > 0 && !strongSelf.output.items.isEmpty {
                        strongSelf.output.items.append(contentsOf: newItems)
                    } else {
                        strongSelf.output.items = newItems
                    }
                    // prefetch the first 10 items images required for the cells
                    strongSelf.prefetchImages(items: Array(newItems.prefix(10)))
                }
            }
            catch let error as APIError {
                // keep whatever the previous state of the items list was, and send an error
                strongSelf.output.error = error.message
            }
            strongSelf.output.isLoading = false
            strongSelf.output.isRefreshing = false
        }
    }
    
    private func prefetchImages(items: [Item]) {
        let prefetchImageURLs = items.compactMap { $0.image }
        environment.imageManager.prefetchImages(prefetchImageURLs, reset: true)
    }
    
    // MARK: Input
    
    private func searchText(_ text: String) {
        guard !text.isEmpty else {
            output.items = []
            output.isLoading = false
            output.isRefreshing = false
            return
        }
        refreshBegin()
    }
    
    private func debounceSearchText() {
        observeBag.add { [weak self] in
            guard let self else { return }
            let text = self.output.searchText
            Task { [weak self] in
                await self?.searchDebounce(text)
            }
        }
    }
    
    func refreshBegin() {
        output.isRefreshing = true
    }
    
    func refresh() {
        // all animations should be completed after refreshBegin and before starting the refresh
        updateData(searchText: output.searchText)
    }

    func loadNextPage() {
        // ensure not to load anymore if the total number of items is already displayed
        guard !output.isLoading && output.hasMorePages else { return }
        updateData(searchText: output.searchText,
                   offset: output.items.count)
    }

    func cellTapped(index: Int) {
        if output.items.indices.contains(index),
           let id = output.items[index].id {
            router.navigate(to: .itemDetail(id: id))
        }
    }
}

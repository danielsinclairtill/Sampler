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
    protocol Contract: SamplerViewModelContract where Output == ItemSearchViewModelBinding.Output {
        var imageManager: ImageManagerContract { get }
        
        /// The items list is in the loading state and ready to refresh the data.
        func refresh()
        /// The user performs an action which intends to refresh the items list.
        func refreshBegin()
        /// The next page of items in the list should load.
        func loadNextPage()
        /// A cell at a row index was tapped in the items list.
        func cellTapped(index: Int)
    }

    class Output: ObservableObject {
        /// The text in the search bar.
        @Published var searchText: String
        /// The items list to display.
        @Published var items: [Item] = []
        /// Show the items list in a refreshing state.
        @Published var isRefreshing: Bool = false
        /// Show an error message to display over the items list.
        @Published var error: String?
        /// The total number of items possible in the list.
        @Published var total: Int = 0
        /// If the items list are loading by refreshing or pagnation.
        @Published fileprivate var isLoading: Bool = false
        /// If the list has more  items that should load.
        @Published var hasMorePages: Bool = false
        
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
class ItemSearchViewModel: ItemSearchViewModelBinding.Contract, ObservableObject {
    @PublishedObject var output: ItemSearchViewModelBinding.Output
    private var cancelBag = Set<AnyCancellable>()
    
    private let environment: any EnvironmentContract
    var imageManager: ImageManagerContract {
        return environment.api.imageManager
    }
    private var router: ItemSearchRouter

    init(output: ItemSearchViewModelBinding.Output = .init(),
         environment: any EnvironmentContract = SamplerEnvironment.shared,
         router: ItemSearchRouter) {
        self.output = output
        self.environment = environment
        self.router = router
        
        listenSearchText()
    }
    
    private func updateData(searchText: String,
                            offset: Int = 0) {
        output.isLoading = true

        guard !searchText.isEmpty else {
            output.items = []
            output.isLoading = false
            output.isRefreshing = false
            return
        }
        
        Task { @MainActor [weak self] in
            guard let strongSelf = self else { return }
            do {
                let results = try await strongSelf.environment.api.request(ItemAPIRequest.Search(text: searchText, offset: offset))
                if results.items.isEmpty {
                    strongSelf.output.items = []
                } else {
                    let newItems = results.items
                    
                    strongSelf.output.total = results.total
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
        environment.api.imageManager.prefetchImages(prefetchImageURLs, reset: true)
    }
    
    // MARK: Binding
    private func listenSearchText() {
        output.$searchText
            .removeDuplicates()
            // debounce search text input to limit how often we request to the API and refresh
            .debounce(for: 0.2,
                      scheduler: DispatchQueue.main)
            .sink { [weak self] searchText in
                guard let self = self else { return }
                guard !searchText.isEmpty else {
                    self.output.items = []
                    self.output.isLoading = false
                    self.output.isRefreshing = false
                    return
                }
                refreshBegin()
            }
            .store(in: &cancelBag)
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

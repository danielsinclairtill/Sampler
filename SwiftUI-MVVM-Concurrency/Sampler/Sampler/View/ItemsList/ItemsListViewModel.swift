//
//  ItemsListViewModel.swift
//  Sampler
//
//
//

import Foundation
import Combine
import SamplerMacros

// MARK: Input + Output
@Mockable
enum ItemsListViewModelBinding {
    protocol Contract: SamplerViewModelContract,
                        ItemsListViewModelBinding.Input where Output == ItemsListViewModelBinding.Output { }
    
    protocol Input {
        /// The view did load.
        func viewDidLoad()
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
        
        init(items: [Item] = [],
             isRefreshing: Bool = false,
             error: String? = nil,
             total: Int = 0,
             isLoading: Bool = false) {
            self.items = items
            self.isRefreshing = isRefreshing
            self.error = error
            self.total = total
            self.isLoading = isLoading
        }
    }
}


// MARK: ViewModel
@Observable
class ItemsListViewModel: ItemsListViewModelBinding.Contract,
                          ItemsListViewModelBinding.Input {
    var output: Output
    typealias Environment = ItemRepositoryProvider &
                            ImageMangagerProvider
    private let environment: Environment
    private var router: ItemsListRouter
    
    private var cancelBag = Set<AnyCancellable>()
    
    var imageManager: ImageManagerContract {
        environment.imageManager
    }
    
    init(output: ItemsListViewModelBinding.Output = .init(),
         environment: Environment = SamplerEnvironment.shared,
         router: ItemsListRouter) {
        self.output = output
        self.environment = environment
        self.router = router
    }
    
    // MARK: Private
    
    private func updateData(offset: Int = 0) {
        output.isLoading = true
        output.error = nil

        Task { @MainActor [weak self] in
            guard let strongSelf = self else { return }
            do {
                let result = try await strongSelf.environment.itemRepository.getItems(offset: offset,
                                                                                    limit: 10)
                if result.data.items.isEmpty {
                    // if no items were recieved, assume there is an issue with the API
                    // keep whatever the previous state of the items list was, and send an error
                    strongSelf.output.error = APIError.serverError.message
                } else {
                    let newItems = result.data.items
                    
                    strongSelf.output.total = result.data.total
                    // if an offset was passed it is a load next page call
                    if offset > 0 && !strongSelf.output.items.isEmpty {
                        strongSelf.output.items.append(contentsOf: newItems)
                    } else {
                        strongSelf.output.items = newItems
                    }
                    strongSelf.output.hasMorePages = strongSelf.output.items.count < strongSelf.output.total
                    
                    // prefetch the first 10 items images required for the cells
                    strongSelf.prefetchImages(items: Array(newItems.prefix(10)))
                }
            } catch let error as APIError {
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
    
    func viewDidLoad() {
        refreshBegin()
    }
    
    func refreshBegin() {
        output.isRefreshing = true
    }

    func refresh() {
        // all animations should be completed after refreshBegin and before starting the refresh
        updateData()
    }
    
    func loadNextPage() {
        // ensure not to load anymore if the total number of items is already displayed
        guard !output.isLoading && output.hasMorePages else { return }
        updateData(offset: output.items.count)
    }

    func cellTapped(index: Int) {
        if output.items.indices.contains(index),
           let id = output.items[index].id {
            router.navigate(to: .itemDetail(id: id))
        }
    }
}

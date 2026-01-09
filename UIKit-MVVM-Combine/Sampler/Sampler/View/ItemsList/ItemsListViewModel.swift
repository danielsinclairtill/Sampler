//
//  SamplerListViewModel.swift
//  Sampler
//
//
//

import Foundation
import Combine

protocol SamplerListViewModelContract: SamplerViewModel
where Input == SamplerListViewModelInput, Output == SamplerListViewModelOutput {
    var imageManager: ImageManagerContract { get }
}

// MARK: Input
class SamplerListViewModelInput: ObservableObject {
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
}

// MARK: Output
class SamplerListViewModelOutput: ObservableObject {
    /// The items list to display.
    @Published fileprivate(set) var items: [Item] = []
    /// Show the items list in a refreshing state.
    @Published fileprivate(set) var isRefreshing: Bool = false
    /// Show an error message to display over the items list.
    @Published fileprivate(set) var error: String = ""
    /// Scroll the items list to the top automatically.
    fileprivate(set) var scrollToTop = PassthroughSubject<Void, Never>()
    /// The total number of items possible in the list.
    @Published fileprivate(set) var total: Int = 0
    /// If the items list are loading by refreshing or pagnation.
    @Published fileprivate var isLoading: Bool = false
}

// MARK: ViewModel
class SamplerListViewModel: SamplerListViewModelContract, ObservableObject {
    @Published var input = SamplerListViewModelInput()
    @Published var output = SamplerListViewModelOutput()
    private let coordinator: ItemsListCoordinator
    private var cancelBag = Set<AnyCancellable>()
    
    private let environment: EnvironmentContract
    var imageManager: ImageManagerContract {
        return environment.api.imageManager
    }
    
    init(environment: EnvironmentContract,
         coordinator: ItemsListCoordinator) {
        self.environment = environment
        self.coordinator = coordinator
        
        // bind inputs and outputs
        setViewDidLoad()
        setRefresh()
        setLoadNextPage()
        setCellTapped()
        setTabBarItemTappedWhileDisplayed()
    }
    
    private func updateData(offset: Int = 0) {
        output.isLoading = true
        environment.api.get(request: ItemRequest.List(offset: offset)) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let data):
                guard !data.items.isEmpty else {
                    // if no items were recieved, assume there is an issue with the API
                    // keep whatever the previous state of the items list was, and send an error
                    strongSelf.output.error = APIError.serverError.message
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
        input.refreshBegin.sink { [weak self] refreshType in
            guard let strongSelf = self else { return }
            strongSelf.output.isRefreshing = true
        }
        .store(in: &cancelBag)

        // all animations should be completed after refreshBegin and before starting the refresh
        input.refresh
            .sink { [weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.updateData()
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
            strongSelf.updateData(offset: strongSelf.output.items.count)
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


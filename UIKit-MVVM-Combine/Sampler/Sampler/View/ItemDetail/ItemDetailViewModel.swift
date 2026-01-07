//
//  ItemDetailViewModel.swift
//  Sampler
//
//  Created by Daniel Till on 2023-08-22.
//

import Foundation
import Combine

protocol ItemDetailViewModelContract: SamplerViewModel
where Input == ItemDetailViewModelInput, Output == ItemDetailViewModelOutput {
    var imageManager: ImageManagerContract { get }
}

// MARK: Input
class ItemDetailViewModelInput: ObservableObject {
    /// The view did load.
    var viewDidLoad = PassthroughSubject<Void, Never>()
}

// MARK: Output
class ItemDetailViewModelOutput: ObservableObject {
    /// The item to display.
    @Published fileprivate(set) var item: Item?
    /// Show an error message to display over the item details.
    @Published fileprivate(set) var error: String = ""
}

// MARK: ViewModel
class ItemDetailViewModel: ItemDetailViewModelContract, ObservableObject {
    @Published var input = ItemDetailViewModelInput()
    @Published var output = ItemDetailViewModelOutput()
    private let coordinator: ItemsListCoordinator
    private var cancelBag = Set<AnyCancellable>()
    
    private let itemId: String
    private let environment: EnvironmentContract
    var imageManager: ImageManagerContract {
        return environment.api.imageManager
    }
    
    required init(itemId: String,
                  environment: EnvironmentContract,
                  coordinator: ItemsListCoordinator) {
        self.itemId = itemId
        self.environment = environment
        self.coordinator = coordinator
        
        // bind inputs and outputs
        setViewDidLoad()
    }
    
    private func setViewDidLoad() {
        input.viewDidLoad.sink { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.environment.api.get(request: SamplerRequests.ItemDetail(id: strongSelf.itemId), result: { [weak self] result in
                guard let strongSelf = self else { return }
                switch result {
                case .success(let item):
                    strongSelf.output.item = item
                case .failure(let error):
                    strongSelf.output.item = nil
                    strongSelf.output.error = error.message
                }
            })
        }
        .store(in: &cancelBag)
    }
}

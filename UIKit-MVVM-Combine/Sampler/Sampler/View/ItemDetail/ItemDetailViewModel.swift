//
//  ItemDetailViewModel.swift
//  Sampler
//
//  Created by Daniel Till on 2023-08-22.
//

import Foundation
import Combine


// MARK: Input + Output
enum ItemDetailViewModelBinding {
    protocol Contract: SamplerViewModel where Input == ItemDetailViewModelBinding.Input,
                                              Output == ItemDetailViewModelBinding.Output {
        var imageManager: ImageManagerContract { get }
    }
    
    class Input: ObservableObject {
        /// The view did load.
        var viewDidLoad = PassthroughSubject<Void, Never>()
    }

    class Output: ObservableObject {
        /// The item to display.
        @Published var item: Item?
        /// The user for the item.
        @Published var user: User?
        /// Show an error message to display over the item details.
        @Published var error: String = ""
        
        init(item: Item? = nil,
             user: User? = nil,
             error: String = "") {
            self.item = item
            self.user = user
            self.error = error
        }
    }
}

// MARK: ViewModel
class ItemDetailViewModel: ItemDetailViewModelBinding.Contract, ObservableObject {
    let input = ItemDetailViewModelBinding.Input()
    let output = ItemDetailViewModelBinding.Output()
    
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
        setUser()
    }
    
    private func setViewDidLoad() {
        input.viewDidLoad.sink { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.environment.api.get(request: ItemRequest.Detail(id: strongSelf.itemId), result: { [weak self] result in
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
    
    private func setUser() {
        output.$item.sink { [weak self] item in
            guard let strongSelf = self else { return }
            guard let userID = item?.userId else { return }
            
            strongSelf.environment.api.get(request: UserRequest.Detail(id: String(userID))) { [weak self] result in
                guard let strongSelf = self else { return }
                switch result {
                case .success(let user):
                    strongSelf.output.user = user
                case .failure:
                    strongSelf.output.user = nil
                }
            }
        }
        .store(in: &cancelBag)
    }
}

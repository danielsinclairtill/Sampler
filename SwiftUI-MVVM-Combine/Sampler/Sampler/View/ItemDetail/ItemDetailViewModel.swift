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
    protocol Contract: SamplerViewModelContract where Input == ItemDetailViewModelBinding.Input,
                                                      Output == ItemDetailViewModelBinding.Output {
        var imageManager: ImageManagerContract { get }
    }
    
    class Input: ObservableObject {
        /// The view did load.
        var viewDidLoad = PassthroughSubject<Void, Never>()
        /// The post button was tapped.
        var tappedPostButton = PassthroughSubject<Void, Never>()
        /// The save button was tapped.
        var tappedSaveButton = PassthroughSubject<Void, Never>()
    }

    class Output: ObservableObject {
        /// The item to display.
        @Published var item: Item?
        /// The user for the item.
        @Published var user: User?
        /// Show an error message to display over the item details.
        @Published var error: String?
        /// If the item is saved on disk or not.
        @Published var isSaved: Bool = false
        /// If the item is currently being saved or not.
        @Published var isSaving: Bool = false

        
        init(item: Item? = nil,
             user: User? = nil,
             error: String? = nil,
             isSaved: Bool = false,
             isSaving: Bool = false) {
            self.item = item
            self.user = user
            self.error = error
            self.isSaved = isSaved
            self.isSaving = isSaving
        }
    }
}

// MARK: ViewModel
class ItemDetailViewModel: ItemDetailViewModelBinding.Contract {
    @PublishedObject var input = ItemDetailViewModelBinding.Input()
    @PublishedObject var output: ItemDetailViewModelBinding.Output
    
    private var cancelBag = Set<AnyCancellable>()
    
    private let itemId: String
    private let environment: any EnvironmentContract
    var imageManager: ImageManagerContract {
        return environment.api.imageManager
    }
    
    required init(itemId: String,
                  output: ItemDetailViewModelBinding.Output = .init(),
                  environment: any EnvironmentContract = SamplerEnvironment.shared) {
        self.itemId = itemId
        self.output = output
        self.environment = environment
        
        // bind inputs and outputs
        setViewDidLoad()
        setPostButton()
        setSaveButton()
        setUser()
        setExternalItemUpdate()
    }
    
    private func updateItem(itemId: String) {
        output.error = nil
        environment.store.get(ItemStoreRequest.GetDetail(id: itemId)) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let item):
                strongSelf.output.item = item
                strongSelf.output.isSaved = true
            case .failure:
                // do nothing
                break
            }
            
            guard strongSelf.output.item == nil else { return }
            strongSelf.environment.api.request(ItemAPIRequest.Detail(id: strongSelf.itemId)) { [weak self] result in
                guard let strongSelf = self else { return }
                switch result {
                case .success(let item):
                    strongSelf.output.item = item
                case .failure(let error):
                    strongSelf.output.item = nil
                    strongSelf.output.error = error.message
                }
            }
        }
    }
    
    private func setViewDidLoad() {
        input.viewDidLoad.sink { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.updateItem(itemId: strongSelf.itemId)
        }
        .store(in: &cancelBag)
    }
    
    
    private func setPostButton() {
        input.tappedPostButton.sink { [weak self] _ in
            guard let self, let item = self.output.item else { return }
            self.environment.api.request(ItemAPIRequest.Create(item: item)) { [weak self] result in
                guard let self else { return }
                switch result {
                case .success(let item):
                    print(item)
                case .failure(let error):
                    output.error = error.message
                }
            }
        }
        .store(in: &cancelBag)
    }
    
    private func setSaveButton() {
        input.tappedSaveButton.sink { [weak self] _ in
            guard let self, let item = self.output.item else { return }
            self.output.isSaving = true
            self.environment.store.store(ItemStoreRequest.StoreDetail(data: item)) { [weak self] result in
                guard let self else { return }
                switch result {
                case .success(let item):
                    print(item)
                    self.output.isSaved = true
                case .failure(let error):
                    self.output.error = error.message
                }
                self.output.isSaving = false
            }
        }
        .store(in: &cancelBag)
    }
    
    private func setUser() {
        output.$item.sink { [weak self] item in
            guard let strongSelf = self else { return }
            guard item?.user == nil,
                  let userID = item?.userId else { return }
            
            strongSelf.environment.api.request(UserAPIRequest.Detail(id: String(userID))) { [weak self] result in
                guard let strongSelf = self else { return }
                switch result {
                case .success(let user):
                    strongSelf.output.item?.user = user
                    strongSelf.output.user = user
                case .failure:
                    strongSelf.output.user = nil
                }
            }
        }
        .store(in: &cancelBag)
    }
    
    func setExternalItemUpdate() {
        NotificationCenter.default.publisher(for: .itemDidUpdate)
            .compactMap { $0.object as? Item } // Extract the ID safely
            .filter { [weak self] updatedItem in updatedItem.id == self?.itemId } // Only react if it matches MY recipe
            .sink { [weak self] _ in
                guard let self else { return }
                self.updateItem(itemId: self.itemId)
            }
            .store(in: &cancelBag)
    }
}

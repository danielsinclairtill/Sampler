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
    protocol Contract: SamplerViewModelContract where Output == ItemDetailViewModelBinding.Output {
        /// The view did load.
        func viewDidLoad()
        /// The post button was tapped.
        func tappedPostButton()
        /// The save button was tapped.
        func tappedSaveButton()
    }
    
    @Observable
    class Output {
        /// The item to display.
        var item: Item?
        /// The user for the item.
        var user: User?
        /// Show an error message to display over the item details.
        var error: String?
        /// If the item is saved on disk or not.
        var isSaved: Bool = false
        /// If the item is currently being saved or not.
        var isSaving: Bool = false

        
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
@Observable
class ItemDetailViewModel: ItemDetailViewModelBinding.Contract {
    var output: Output
    private var cancelBag = Set<AnyCancellable>()
    
    private let itemId: String
    private let environment: any EnvironmentContract
    
    required init(itemId: String,
                  output: Output = .init(),
                  environment: any EnvironmentContract = SamplerEnvironment.shared) {
        self.itemId = itemId
        self.output = output
        self.environment = environment
        
        setExternalItemUpdate()
    }
    
    // MARK: Private
    
    private func updateItem(itemId: String) {
        environment.store.get(ItemStoreRequest.GetDetail(id: itemId)) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let item):
                self.output.item = item
                self.output.isSaved = true
            case .failure:
                // do nothing
                break
            }
            
            guard self.output.item == nil else { return }
            Task { @MainActor [weak self] in
                guard let self else { return }
                do {
                    let item = try await self.environment.api.request(ItemAPIRequest.Detail(id: itemId))
                    self.output.item = item
                    try await self.updateUser(userID: item.userId)
                } catch let error as APIError {
                    self.output.item = nil
                    self.output.error = error.message
                }
            }
        }
    }
    
    private func updateUser(userID: String?) async throws {
        guard let userID else {
            output.user = nil
            return
        }
        
        do {
            let user = try await environment.api.request(UserAPIRequest.Detail(id: String(userID)))
            output.item?.user = user
        } catch let error as APIError {
            output.item?.user = nil
            output.error = error.message
        }
    }
    
    private func setExternalItemUpdate() {
        NotificationCenter.default.publisher(for: .itemDidUpdate)
            .compactMap { $0.object as? Item } // Extract the ID safely
            .filter { [weak self] updatedItem in updatedItem.id == self?.itemId } // Only react if it matches MY recipe
            .sink { [weak self] _ in
                guard let self else { return }
                self.updateItem(itemId: self.itemId)
            }
            .store(in: &cancelBag)
    }
    
    // MARK: Input
    
    func viewDidLoad() {
        updateItem(itemId: itemId)
    }
    
    func tappedPostButton() {
        guard let item = output.item else { return }
        Task { @MainActor [weak self] in
            guard let self else { return }
            do {
                let result = try await self.environment.api.request(ItemAPIRequest.Create(item: item))
                print(result)
            } catch let error as APIError {
                self.output.item = nil
                self.output.error = error.message
            }
        }
    }
    
    func tappedSaveButton() {
        guard let item = self.output.item else { return }
        Task { @MainActor [weak self] in
            guard let self else { return }
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
    }
}

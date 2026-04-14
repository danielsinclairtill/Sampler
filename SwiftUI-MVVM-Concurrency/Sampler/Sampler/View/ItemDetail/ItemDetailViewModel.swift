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
    protocol Contract: SamplerViewModelContract where
    Input == ItemDetailViewModelBinding.Input,
    Output == ItemDetailViewModelBinding.Output { }
    
    protocol Input {
        /// The view did load.
        func viewDidLoad() async
        /// The post button was tapped.
        func tappedPostButton() async
        /// The save button was tapped.
        func tappedSaveButton() async
        /// The like button was tapped.
        func tappedLikeButton()
    }
    
    @Observable
    class Output {
        /// The item to display.
        var item: Item?
        /// Show an error message to display over the item details.
        var error: String?
        /// If the item is saved on disk or not.
        var isSaved: Bool = false
        /// If the item is currently being saved or not.
        var isSaving: Bool = false
        /// If the item is liked.
        var isLiked: Bool = false

        
        init(item: Item? = nil,
             error: String? = nil,
             isSaved: Bool = false,
             isSaving: Bool = false,
             isLiked: Bool = false) {
            self.item = item
            self.error = error
            self.isSaved = isSaved
            self.isSaving = isSaving
            self.isLiked = isLiked
        }
    }
}

// MARK: ViewModel
@Observable
class ItemDetailViewModel: ItemDetailViewModelBinding.Contract,
                           ItemDetailViewModelBinding.Input {
    var output: Output
    typealias Environment = ItemRepositoryProvider &
                            UserRepositoryProvider &
                            LikeManagerProvider
    private let environment: Environment
            
    private var observeBag = ObserveBag()
    private var cancelBag = Set<AnyCancellable>()
    
    private let itemId: String
    
    public required init(itemId: String,
                         output: Output = .init(),
                         environment: Environment = SamplerEnvironment.shared) {
        self.itemId = itemId
        output.isLiked = environment.likeManager.isLiked(itemId)
        self.output = output
        self.environment = environment
        
        setExternalItemUpdate()
        syncLike()
    }
    
    // MARK: Private
    
    private func updateItem(itemId: String) async {
        output.error = nil

        // item from store
        do {
            let item = try await environment.itemRepository.getItem(id: itemId)
            output.item = item.data
            output.isSaved = item.source == .store
            
            if item.source != .store {
                await updateUser(userID: output.item?.userId)
            }
        } catch {
            switch error {
            case let e as StoreError: output.error = e.message
            case let e as APIError: output.error = e.message
            default: output.error = nil
            }
        }
    }
    
    private func updateUser(userID: String?) async {
        guard let userID else {
            output.item?.user = nil
            return
        }
        
        do {
            let user = try await environment.userRepository.getUser(id: userID)
            output.item?.user = user.data
        } catch {
            switch error {
            case let e as APIError: output.error = e.message
            default: output.error = nil
            }
        }
    }
    
    private func setExternalItemUpdate() {
        NotificationCenter.default.publisher(for: .itemDidUpdate)
            .compactMap { $0.object as? Item } // Extract the ID safely
            .filter { [weak self] updatedItem in updatedItem.id == self?.itemId } // Only react if it matches MY recipe
            .sink { [weak self] _ in
                Task { @MainActor [weak self] in
                    guard let self else { return }
                    await self.updateItem(itemId: self.itemId)
                }
            }
            .store(in: &cancelBag)
    }
    
    private func syncLike() {
        observeBag.add { [weak self] in
            guard let self else { return }
            self.output.isLiked = self.environment.likeManager.isLiked(self.itemId)
        }
    }
    
    // MARK: Input
    
    func viewDidLoad() async {
        await updateItem(itemId: itemId)
    }
    
    func tappedPostButton() async {
        guard let item = output.item else { return }
        do {
            let result = try await environment.itemRepository.createItem(item: item)
            print(result)
        } catch {
            switch error {
            case let e as APIError:   output.error = e.message
            default:                  output.error = nil
            }
        }
    }
    
    func tappedSaveButton() async {
        guard let item = output.item else { return }
        output.isSaving = true
        do {
            let item = try await environment.itemRepository.saveItem(item: item)
            print(item)
            output.isSaved = true
        } catch {
            switch error {
            case let e as APIError:   output.error = e.message
            default:                  output.error = nil
            }
        }
        output.isSaving = false
    }
    
    func tappedLikeButton() {
        guard let item = output.item,
              let id = item.id else { return }
        environment.likeManager.toggleLike(id)
    }
}

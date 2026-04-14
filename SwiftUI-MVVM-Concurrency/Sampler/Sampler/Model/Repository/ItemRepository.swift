//
//  ItemRepository.swift
//  Sampler
//
//  Created by Daniel on 2026-03-31.
//

import Foundation

// Repository
struct DataResult<T> {
    let data: T
    let source: DataSource

    enum DataSource {
        case api
        case store
    }
}

protocol ItemRepositoryContract {
    func getItem(id: String) async throws -> DataResult<Item>
    func getItems(offset: Int,
                  limit: Int) async throws -> DataResult<ItemAPIRequest.List.Response>
    func createItem(item: Item) async throws -> DataResult<Item>
    func saveItem(item: Item) async throws -> DataResult<Item>
    
    func searchItem(text: String,
                    offset: Int,
                    limit: Int) async throws -> DataResult<ItemAPIRequest.Search.Response>
}

class ItemRepository: ItemRepositoryContract {
    private let api: APIContract
    private let store: StoreContract
    
    init(api: APIContract, store: StoreContract) {
        self.api = api
        self.store = store
    }

    func getItem(id: String) async throws -> DataResult<Item> {
        // check if item is available in store
        if let item = try await store.get(ItemStoreRequest.GetDetail(id: id)) {
            return .init(data: item, source: .store)
        }
        
        // item from API
        let item = try await api.request(ItemAPIRequest.Detail(id: id))
        return .init(data: item, source: .api)
    }
    
    func getItems(offset: Int = 0,
                  limit: Int = 10) async throws -> DataResult<ItemAPIRequest.List.Response> {
        let result = try await api.request(ItemAPIRequest.List(offset: offset, limit: limit))
        return .init(data: result, source: .api)
    }
    
    func createItem(item: Item) async throws -> DataResult<Item> {
        let result = try await api.request(ItemAPIRequest.Create(item: item))
        return .init(data: result, source: .api)
    }
    
    func saveItem(item: Item) async throws -> DataResult<Item> {
        let result = try await store.store(ItemStoreRequest.StoreDetail(data: item))
        return .init(data: result, source: .store)
    }
    
    func searchItem(text: String,
                    offset: Int = 0,
                    limit: Int = 10) async throws -> DataResult<ItemAPIRequest.Search.Response> {
        let result = try await api.request(ItemAPIRequest.Search(text: text, offset: offset, limit: limit))
        return .init(data: result, source: .api)
    }
}

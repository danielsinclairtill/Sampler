//
//  SamplerTestStore.swift
//  Sampler
//
//  Created by Daniel on 2026-02-04.
//

class SamplerTestStore: StoreContract {
    var getError: StoreError?
    var getResult: Any?

    func get<R: RequestStoreGetContract>(_ request: R) async throws(StoreError) -> R.Data? {
        if let error = getError { throw error }
        return getResult as? R.Data
    }

    func getList<R: RequestStoreGetListContract>(_ request: R) async throws(StoreError) -> R.DataList {
        if let error = getError { throw error }
        return getResult as? R.DataList ?? R.DataList()
    }

    func store<R: RequestStoreStoreContract>(_ request: R) async throws(StoreError) -> R.Data {
        if let error = getError { throw error }
        guard let result = getResult as? R.Data else { throw StoreError.readError }
        return result
    }
    
    func wipe() async throws(StoreError) {}
}

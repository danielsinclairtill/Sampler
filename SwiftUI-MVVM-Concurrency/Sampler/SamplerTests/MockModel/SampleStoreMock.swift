//
//  SampleStoreMock.swift
//  Sampler
//
//  Created by Daniel on 2026-02-02.
//

import Foundation
@testable import Sampler

class SampleStoreMock: StoreContract {
    var getError: StoreError?
    var getResult: Any?

    func get<R: RequestStoreGetContract>(_ request: R) async throws -> R.Data {
        if let error = getError { throw error }
        guard let getResult else { throw StoreError.empty }
        return getResult as! R.Data
    }

    func getList<R: RequestStoreGetListContract>(_ request: R) async throws -> R.DataList {
        if let error = getError { throw error }
        guard let getResult else { throw StoreError.empty }
        return getResult as! R.DataList
    }

    func store<R: RequestStoreStoreContract>(_ request: R) async throws {}
    func wipe() async throws {}
}

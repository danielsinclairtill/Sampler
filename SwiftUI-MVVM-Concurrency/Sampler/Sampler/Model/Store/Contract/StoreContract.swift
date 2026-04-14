//
//  StoreContract.swift
//  Stories
//
//
//
//

import Foundation

public protocol StoreContract {
    func get<R: RequestStoreGetContract>(_ request: R) async throws -> R.Data?
    func getList<R: RequestStoreGetListContract>(_ request: R) async throws -> R.DataList
    func store<R: RequestStoreStoreContract>(_ request: R) async throws -> R.Data
    func wipe() async throws
}

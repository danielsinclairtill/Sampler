//
//  StoreRequestContract.swift
//  Sampler
//
//  Created by Daniel on 2026-01-30.
//

import Foundation

public protocol RequestStoreStoreContract {
    associatedtype Data: StoreConvertible
    var data: Data { get }
}


public enum RequestStoreGetType {
    case id(_ id: String)
    case all
}

public protocol RequestStoreGetListContract {
    associatedtype Data: StoreConvertible
    associatedtype DataList = [Data]
}

public protocol RequestStoreGetContract {
    associatedtype Data: StoreConvertible
    var id: String { get }
}

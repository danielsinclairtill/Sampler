//
//  ItemStoreRequest.swift
//  Sampler
//
//  Created by Daniel on 2026-01-30.
//

import Foundation

public struct ItemStoreRequest {
    public struct GetDetail: RequestStoreGetContract {
        public typealias Data = Item
        public let id: String
    }
    
    public struct GetDetails: RequestStoreGetListContract {
        public typealias Data = Item
    }
    
    public struct StoreDetail: RequestStoreStoreContract {
        public var data: Item
        public var timeoutInterval: TimeInterval = 10.0
    }
}

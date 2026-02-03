//
//  SampleStoreMock.swift
//  Sampler
//
//  Created by Daniel on 2026-02-02.
//

import Foundation
@testable import Sampler

class SampleStoreMock: StoreContract {
    func get<R>(_ request: R, result: ((Result<R.Data, Sampler.StoreError>) -> Void)?) where R : Sampler.RequestStoreGetContract {
        // no op
        result?(.failure(.empty))
    }
    
    func getList<R>(_ request: R, result: ((Result<R.DataList, Sampler.StoreError>) -> Void)?) where R : Sampler.RequestStoreGetListContract {
        // no op
        result?(.failure(.empty))
    }
    
    func store<R>(_ request: R, result: ((Result<Void, Sampler.StoreError>) -> Void)?) where R : Sampler.RequestStoreStoreContract {
        // no op
        result?(.failure(.empty))
    }
    
    func wipe(result: ((Result<Void, Sampler.StoreError>) -> Void)?) {
        // no op
    }
}

//
//  SamplerTestStore.swift
//  Sampler
//
//  Created by Daniel on 2026-02-04.
//

class SamplerTestStore: StoreContract {
    func get<R>(_ request: R, result: ((Result<R.Data, StoreError>) -> Void)?) where R : RequestStoreGetContract {
        // no op
    }
    
    func getList<R>(_ request: R,
                    result: ((Result<R.DataList, StoreError>) -> Void)?) where R : RequestStoreGetListContract {
        // no op
    }
    
    func store<R>(_ request: R, result: ((Result<Void, StoreError>) -> Void)?) where R : RequestStoreStoreContract {
        // no op
    }
    
    func wipe(result: ((Result<Void, StoreError>) -> Void)?) {
        // no op
    }
}

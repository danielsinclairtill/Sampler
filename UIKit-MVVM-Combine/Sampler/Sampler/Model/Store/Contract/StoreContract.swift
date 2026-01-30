//
//  StoreContract.swift
//  Stories
//
//
//
//

import Foundation

public protocol StoreContract {
    func get<R: RequestStoreGetContract>(_ request: R,
                                         result: ((Result<R.Data, StoreError>) -> Void)?)
    
    func getList<R: RequestStoreGetListContract>(_ request: R,
                                                 result: ((Result<R.DataList, StoreError>) -> Void)?)
    
    
    func store<R: RequestStoreStoreContract>(_ request: R,
                                             result: ((Result<Void, StoreError>) -> Void)?)
}

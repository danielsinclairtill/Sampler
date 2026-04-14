//
//  SampleStoreMock.swift
//  Sampler
//
//  Created by Daniel on 2026-02-02.
//

import Foundation
@testable import Sampler

class SampleStoreMock: StoreContract {
    /// List of mock get responses to occur during an store session in order. Can be a success or error response.
    var mockGetResponses: [Result<Decodable?, StoreError>] = []
    
    /// List of mock list get responses to occur during an store session in order. Can be a success or error response.
    var mockGetListResponses: [Result<Decodable, StoreError>] = []
    
    /// List of mock store responses to occur during an API session in order. Can be a success or error response.
    var mockStoreResponses: [Result<Decodable, StoreError>] = []

    /// List of mock get requests called during this store session in order.
    var mockGetRequestsCalled: [any RequestStoreGetContract] = []
    
    /// List of mock get list requests called during this store session in order.
    var mockGetListRequestsCalled: [any RequestStoreGetListContract] = []
    
    /// List of mock store requests called during this store session in order.
    var mockStoreRequestsCalled: [any RequestStoreStoreContract] = []
    
    
    func get<R: RequestStoreGetContract>(_ request: R) async throws -> R.Data? {
        try MockRequest.mockOptionalResponse(request: request,
                                             mockResponses: &mockGetResponses,
                                             called: &mockGetRequestsCalled)
    }
    
    func getList<R: RequestStoreGetListContract>(_ request: R) async throws -> R.DataList {
        try MockRequest.mockResponse(request: request,
                                     mockResponses: &mockGetListResponses,
                                     called: &mockGetListRequestsCalled)
    }
    
    func store<R: RequestStoreStoreContract>(_ request: R) async throws -> R.Data {
        try MockRequest.mockResponse(request: request,
                                     mockResponses: &mockStoreResponses,
                                     called: &mockStoreRequestsCalled)
    }
    
    func wipe() async throws {
        // no op
    }
}

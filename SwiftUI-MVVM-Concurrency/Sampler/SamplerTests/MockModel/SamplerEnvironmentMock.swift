//
//  SamplerEnvironmentMock.swift
//  SamplerTests
//
//
//
//

import Foundation
@testable import Sampler

class SamplerEnvironmentMock: EnvironmentContract {
    
    
    var api: APIContract { mockApi }
    var state: any SamplerStateContract { mockState }
    var store: StoreContract { mockStore }
    var likeManager: any LikeManagerContract { mockLikeManager }
    
    let mockApi: SamplerAPIMock = SamplerAPIMock()
    let mockStore: SampleStoreMock = SampleStoreMock()
    let mockState: SamplerStateManagerMock = SamplerStateManagerMock()
    let mockLikeManager: SamplerLikeManagerMock = SamplerLikeManagerMock()

    /// Reset and clear the mock environment state.
    func reset() {
        mockApi.reset()
    }
}

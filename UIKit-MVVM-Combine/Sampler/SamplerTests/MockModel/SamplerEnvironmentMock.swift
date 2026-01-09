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
    var api: APIContract { return mockApi }
    var state: SamplerStateContract { return mockState }
    
    let mockApi: SamplerAPIMock = SamplerAPIMock()
    let mockState: SamplerStateManagerMock = SamplerStateManagerMock()
    
    /// Reset and clear the mock environment state.
    func reset() {
        mockApi.reset()
    }
}

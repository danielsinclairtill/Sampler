//
//  SamplerAPI.swift
//  SamplerTests
//
//
//
//

import Foundation
@testable import Sampler

class SamplerAPIMock: APIContract {
    /// List of mock responses to occur during an API session in order. Can be a success or error response.
    var mockAPIResponses: [Result<Decodable, APIError>] = []
    /// List of mock requests called during this API session in order.
    var mockAPIRequestsCalled: [any RequestAPIContract] = []
    
    /// Function to reset API session state.
    func reset() {
        mockAPIResponses = []
        mockAPIRequestsCalled = []
        mockImageManager.reset()
    }

    let baseUrl = "https://www.test.com/"

    var imageManager: ImageManagerContract { return mockImageManager }
    let mockImageManager: SamplerImageManagerMock = SamplerImageManagerMock()

    func request<R: RequestAPIContract>(_ request: R) async throws -> R.Response {
        try MockRequest.mockResponse(request: request,
                                     mockResponses: &mockAPIResponses,
                                     called: &mockAPIRequestsCalled)
    }
}

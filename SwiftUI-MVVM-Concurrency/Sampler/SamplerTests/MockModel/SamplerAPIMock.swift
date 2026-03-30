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
        // log called request
        mockAPIRequestsCalled.append(request)

        // traverse through defined mock responses to find the correct one to return for this request
        for (index, mockAPIResponse) in mockAPIResponses.enumerated() {
            switch mockAPIResponse {
            case .success(let mockData):
                // attempt to make mock response into the current get request response
                if let responseData = mockData as? R.Response {
                    // mock response handled, remove from queue
                    mockAPIResponses.remove(at: index)
                    return responseData
                }
            case .failure(let mockError):
                // mock response handled, remove from queue
                mockAPIResponses.remove(at: index)
                throw mockError
            }
        }
        
        // no mock for this request was found, raise an error
        fatalError("Could not mock this response!")
    }
}

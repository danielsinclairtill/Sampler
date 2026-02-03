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
    var mockAPIRequestsCalled: [RequestAPIContract] = []
    
    /// Function to reset API session state.
    func reset() {
        mockAPIResponses = []
        mockAPIRequestsCalled = []
        mockImageManager.reset()
    }

    let baseUrl = "https://www.test.com/"

    var imageManager: ImageManagerContract { return mockImageManager }
    let mockImageManager: SamplerImageManagerMock = SamplerImageManagerMock()

    func request<R>(_ request: R, result: ((Result<R.Response, Sampler.APIError>) -> Void)?) where R : Sampler.RequestAPIContract {
        // log called request
        mockAPIRequestsCalled.append(request)

        // traverse through defined mock responses to find the correct one to return for this request
        for (index, mockAPIResponse) in mockAPIResponses.enumerated() {
            switch mockAPIResponse {
            case .success(let mockData):
                // attempt to make mock response into the current get request response
                if let responseData = mockData as? R.Response {
                    result?(Result<R.Response, APIError>.success(responseData))
                    // mock response handled, remove from queue
                    mockAPIResponses.remove(at: index)
                    return
                }
            case .failure(let mockError):
                result?(Result<R.Response, APIError>.failure(mockError))
                // mock response handled, remove from queue
                mockAPIResponses.remove(at: index)
                return
            }
        }
        
        // no mock for this request was found, raise an error
        fatalError("Could not mock this response!")
    }
}

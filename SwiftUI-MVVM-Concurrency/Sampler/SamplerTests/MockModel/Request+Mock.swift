//
//  Request+Mock.swift
//  Sampler
//
//  Created by Daniel on 2026-04-14.
//

enum MockRequest {
    static func mockResponse<Request,
                             ResponseData,
                             Error>(request: Request,
                                    mockResponses: inout Array<Result<Decodable, Error>>,
                                    called: inout Array<Request>) throws -> ResponseData {
        // log called request
        called.append(request)
        
        // traverse through defined mock responses to find the correct one to return for this request
        for (index, mockAPIResponse) in mockResponses.enumerated() {
            switch mockAPIResponse {
            case .success(let mockData):
                // attempt to make mock response into the current get request response
                if let responseData = mockData as? ResponseData {
                    // mock response handled, remove from queue
                    mockResponses.remove(at: index)
                    return responseData
                }
            case .failure(let mockError):
                // mock response handled, remove from queue
                mockResponses.remove(at: index)
                throw mockError
            }
        }
        
        // no mock for this request was found, raise an error
        fatalError("Could not mock this response!")
    }
    
    static func mockOptionalResponse<Request,
                                     ResponseData,
                                     Error>(request: Request,
                                            mockResponses: inout Array<Result<Decodable?, Error>>,
                                            called: inout Array<Request>) throws -> ResponseData? {
        // log called request
        called.append(request)
        
        // traverse through defined mock responses to find the correct one to return for this request
        for (index, mockAPIResponse) in mockResponses.enumerated() {
            switch mockAPIResponse {
            case .success(let mockData):
                // attempt to make mock response into the current get request response
                if let responseData = mockData as? ResponseData {
                    // mock response handled, remove from queue
                    mockResponses.remove(at: index)
                    return responseData
                } else {
                    return nil
                }
            case .failure(let mockError):
                // mock response handled, remove from queue
                mockResponses.remove(at: index)
                throw mockError
            }
        }
        
        // no mock for this request was found, raise an error
        fatalError("Could not mock this response!")
    }
}

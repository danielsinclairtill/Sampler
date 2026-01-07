//
//  APIContract.swift
//  Sampler
//
//
//
//

import Foundation

public protocol APIContract {
    /// Base URL of the API being utilized.
    var baseUrl: String { get }

    /// Manager used to download, prefetch, and cache images.
    var imageManager: ImageManagerContract { get }
    
    /// Function to handle a GET request for a certain API request, which must conform to the APIRequestContract.
    func get<R: APIRequestContract>(request: R,
                                    result: ((Result<R.Response, APIError>) -> Void)?)
}

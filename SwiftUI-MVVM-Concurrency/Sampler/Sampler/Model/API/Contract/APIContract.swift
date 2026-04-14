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
    
    /// Function to handle a GET request for a certain API request, which must conform to the APIRequestContract.
    func request<R: RequestAPIContract>(_ request: R) async throws -> R.Response
}

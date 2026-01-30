//
//  RequestContract.swift
//  Sampler
//
//
//
//

import Foundation

public enum RequestMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

public protocol RequestContract {
    /// Path to the API endpoint, excluding the base URL.
    var path: String { get }
    /// Parameters for the request.
    var parameters: [String: String]? { get }
    /// The request http method.
    var method: RequestMethod { get }
    /// Any additional headers added to the request.
    var headers: [String: String]? { get }
    /// The request body.
    var body: [String: Any]? { get }
    /// Time the API request should attempt to connect before timing out and returning an error.
    var timeoutInterval: TimeInterval { get }
}

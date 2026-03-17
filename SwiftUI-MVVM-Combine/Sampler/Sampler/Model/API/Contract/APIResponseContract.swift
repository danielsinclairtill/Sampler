//
//  ResponseContract.swift
//  Sampler
//
//
//
//

import Foundation

public protocol APIResponseContract {
    /// The decodable response of the API request.
    associatedtype Response: Decodable
}

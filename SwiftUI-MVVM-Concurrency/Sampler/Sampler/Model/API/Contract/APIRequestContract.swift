//
//  APIRequestContract.swift
//  Sampler
//
//
//
//

import Foundation
import SamplerAPI

public protocol APIResponseContract<GraphData> {
    /// The decodable response of the API request.
    associatedtype GraphData
    static func convert(data: GraphData) -> Self
}

public protocol APIQueryContract {
    /// The decodable response of the API request.
    associatedtype Query: GraphQLQuery where Query.ResponseFormat == SingleResponseFormat
    associatedtype Response: APIResponseContract<Query.Data>

    var query: Query { get }
}

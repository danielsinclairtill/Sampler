//
//  SamplerAPI.swift
//  Sampler
//
//
//

import Apollo
import Foundation
import SamplerAPI

class SamplerAPI: APIContract {
    public static let baseUrl = "https://gorest.co.in/public/v2/graphql"
    private let client: ApolloClient = ApolloClient(url: URL(string: baseUrl)!)
    
    let imageManager: ImageManagerContract = SamplerAPIImageManager()
    
    func query<R>(_ request: R) async throws -> R.Response where R : APIQueryContract {
        let results = try await client.fetch(query: request.query)
        guard let data = results.data else { throw APIError.serverError }
        return R.Response.convert(data: data)
    }
}

//
//  SamplerAPI.swift
//  Sampler
//
//  Created by Daniel on 2026-03-24.
//

import Apollo
import Foundation

class SamplerGraphQLAPI {
    static private let baseUrl = "https://gorest.co.in/public/v2/graphql"

    static let shared: ApolloClient = {
            return ApolloClient(url: URL(string: baseUrl)!)
    }()
}

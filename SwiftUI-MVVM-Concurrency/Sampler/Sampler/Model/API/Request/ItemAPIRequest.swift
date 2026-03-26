//
//  ItemRequest.swift
//  Sampler
//
//
//
//

import Foundation
import SamplerAPI

public struct ItemAPIRequest {
    /**
     Retrieves a page of list of items to display on the 'Sampler' home timeline.

     - Response:
        - stories: list of items
        - nextUrl: next URL  to use for paginated results
     */
    public struct List: APIQueryContract {
        /// Retrieves the next page of items to display on the 'Sampler' timeline.
        /// - Parameter offset: the offset that is the starting index of the next page
        /// - Parameter limit: The limit of items to get in the response.
        init(after: String? = nil,
             limit: Int32 = 10,
             accessToken: String? = SamplerEnvironment.shared.state.user?.accessToken) {
            self.after = after
            self.limit = limit
        }
        
        public let after: String?
        public let limit: Int32
                
        public struct Response: APIResponseContract {
            public let items: [Item]
            public let hasNextPage: Bool
            public let endCursor: String?
            
            public static func convert(data: ItemListQuery.Data) -> Self {
                return Self(items: (data.posts.nodes ?? []).compactMap { Item.create(from: $0?.fragments.itemCompactGraph) },
                            hasNextPage: data.posts.pageInfo.hasNextPage,
                            endCursor: data.posts.pageInfo.endCursor)
            }
        }
        
        public var query: ItemListQuery {
            ItemListQuery(first: .some(limit), after: .none)
        }
    }
}

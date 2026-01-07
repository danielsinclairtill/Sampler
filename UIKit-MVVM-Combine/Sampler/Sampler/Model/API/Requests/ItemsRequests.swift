//
//  SamplerRequests.swift
//  Sampler
//
//
//
//

import Foundation

public struct SamplerRequests {
    /**
     Retrieves a page of list of items to display on the 'Sampler' timeline.

     - Response:
        - stories: list of stories
        - nextUrl: next URL  to use for paginated results
     */
    public struct SamplerTimelinePage: APIRequestContract {
        /// Retrieves the next page of items to display on the 'Sampler' timeline.
        /// - Parameter offset: the offset that is the starting index of the next page
        init(offset: Int = 0) {
            parameters?.updateValue(String(offset), forKey: "offset")
        }
        
        public let path: String = "stories"
        public var parameters: [String : String]? = [
            "offset": "0",
            "limit": "10",
            "fields": "stories(id,title,cover,user,description,tags)",
            "filter": "new",
        ]
        public var timeoutInterval: TimeInterval = 10
        
        public struct Response: Decodable {
            public let items: [Item]
            public let nextUrl: URL
        }
    }
    
    /**
     Retrieves the details of an item.

     - Response: Item object
     */
    public struct ItemDetail: APIRequestContract {
        /// Retrieves the details of an item.
        /// - Parameter id: the unqiue id of the story
        init(id: String) {
            parameters?.updateValue(id, forKey: "id")
            path = "stories/\(id)"
        }
        
        public var path: String
        public var parameters: [String : String]? = [
            "fields": "id,title,cover,user,description,tags",
        ]
        public var timeoutInterval: TimeInterval = 10
        
        public typealias Response = Item
    }
}

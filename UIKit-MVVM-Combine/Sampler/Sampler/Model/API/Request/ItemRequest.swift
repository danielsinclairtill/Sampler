//
//  ItemRequest.swift
//  Sampler
//
//
//
//

import Foundation

public struct ItemRequest {
    /**
     Retrieves a page of list of items to display on the 'Sampler' timeline.

     - Response:
        - stories: list of items
        - nextUrl: next URL  to use for paginated results
     */
    public struct List: APIRequestContract {
        /// Retrieves the next page of items to display on the 'Sampler' timeline.
        /// - Parameter offset: the offset that is the starting index of the next page
        init(offset: Int = 0,
             limit: Int = 10) {
            parameters?.updateValue(String(offset), forKey: "skip")
            parameters?.updateValue(String(limit), forKey: "limit")
        }
        
        public let path: String = "/recipes"
        public var parameters: [String : String]? = [
            "skip": "0",
            "limit": "10",
            "select": "id,name,body,ingredients,difficulty,tags,userId,image",
        ]
        public var timeoutInterval: TimeInterval = 10
        
        public struct Response: Decodable {
            public let items: [Item]
            public let total: Int
            public let offset: Int
            
            enum CodingKeys: String, CodingKey {
                case items = "recipes"
                case total
                case offset = "skip"
            }
        }
    }
    
    /**
     Retrieves the details of an item.

     - Response: Item object
     */
    public struct Detail: APIRequestContract {
        /// Retrieves the details of an item.
        /// - Parameter id: the unqiue id of the item
        init(id: String) {
            parameters?.updateValue(id, forKey: "id")
            path = "/recipes/\(id)"
        }
        
        public var path: String
        public var parameters: [String : String]? = [
            "select": "id,name,body,ingredients,difficulty,tags,userId,image",
        ]
        public var timeoutInterval: TimeInterval = 10
        
        public typealias Response = Item
    }
}

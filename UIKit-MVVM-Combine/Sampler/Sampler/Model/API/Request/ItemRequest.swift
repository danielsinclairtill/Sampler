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
     Retrieves a page of list of items to display on the 'Sampler' home timeline.

     - Response:
        - stories: list of items
        - nextUrl: next URL  to use for paginated results
     */
    public struct List: RequestAPIContract {
        /// Retrieves the next page of items to display on the 'Sampler' timeline.
        /// - Parameter offset: the offset that is the starting index of the next page
        /// - Parameter limit: The limit of items to get in the response.
        init(offset: Int = 0,
             limit: Int = 10,
             accessToken: String? = SamplerEnvironment.shared.state.user?.accessToken) {
            parameters?.updateValue(String(offset), forKey: "skip")
            parameters?.updateValue(String(limit), forKey: "limit")
            
            if let accessToken {
                headers = ["Authorization": "Bearer \(accessToken)"]
            }
        }
        
        public let path: String = "/recipes"
        public var parameters: [String : String]? = [
            "skip": "0",
            "limit": "10",
            "select": "id,name,body,ingredients,difficulty,tags,userId,image",
        ]
        public let method: APIRequestMethod = .get
        public var headers: [String : String]?
        public let body: [String: Any]? = nil
        public let timeoutInterval: TimeInterval = 10
        
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
     Retrieves a page of list of items baed on some search text.

     - Response:
        - stories: list of items
        - nextUrl: next URL  to use for paginated results
     */
    public struct Search: RequestAPIContract {
        /// Retrieves the next page of items to display on the 'Sampler' timeline.
        /// - Parameter text: The search text.
        /// - Parameter offset: the offset that is the starting index of the next page
        /// - Parameter limit: The limit of items to get in the response.
        init(text: String,
             offset: Int = 0,
             limit: Int = 10) {
            parameters?.updateValue(text, forKey: "q")
            parameters?.updateValue(String(offset), forKey: "skip")
            parameters?.updateValue(String(limit), forKey: "limit")
        }
        
        public let path: String = "/recipes/search"
        public var parameters: [String : String]? = [
            "skip": "0",
            "limit": "10",
            "select": "id,name,body,ingredients,difficulty,tags,userId,image",
        ]
        public let method: APIRequestMethod = .get
        public var headers: [String : String]?
        public let body: [String: Any]? = nil
        public let timeoutInterval: TimeInterval = 10
        
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
    public struct Detail: RequestAPIContract {
        /// Retrieves the details of an item.
        /// - Parameter id: the unqiue id of the item
        init(id: String) {
            path = "/recipes/\(id)"
        }
        
        public let path: String
        public var parameters: [String : String]? = [
            "select": "id,name,body,ingredients,difficulty,tags,userId,image",
        ]
        public let method: APIRequestMethod = .get
        public var headers: [String : String]?
        public let body: [String: Any]? = nil
        public let timeoutInterval: TimeInterval = 10
        
        public typealias Response = Item
    }
}

//
//  UserRequest.swift
//  Sampler
//
//  Created by Daniel on 2026-01-07.
//

import Foundation

public struct UserAPIRequest {
    /**
     Retrieves the details of a user.

     - Response: User object
     */
    public struct Detail: RequestAPIContract {
        /// Retrieves the details of a user.
        /// - Parameter id: the unqiue id of the user
        init(id: String) {
            parameters?.updateValue(id, forKey: "id")
            path = "/users/\(id)"
        }
        
        public let path: String
        public var parameters: [String : String]? = [
            "select": "id,firstName,lastName,username,image",
        ]
        public let method: APIRequestMethod = .get
        public var headers: [String : String]?
        public let body: [String: Any]? = nil
        public let timeoutInterval: TimeInterval = 10
        
        public typealias Response = User
    }
}

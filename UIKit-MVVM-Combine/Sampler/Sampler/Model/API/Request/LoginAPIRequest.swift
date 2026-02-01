//
//  LoginRequest.swift
//  Sampler
//
//  Created by Daniel on 2026-01-10.
//

import Foundation

public struct LoginAPIRequest {
    /**
     Attempts to login with a username and password.

     - Response: User object
     */
    public struct Login: RequestAPIContract {
        /// Retrieves the details of a user.
        /// - Parameter id: the unqiue id of the user
        init(username: String,
             password: String) {
            body = .dictionary([
                "username": username,
                "password": password
            ])
        }
        
        public var path: String = "/auth/login"
        public var parameters: [String : String]? = nil
        public var method: APIRequestMethod = .post
        public var headers: [String : String]?
        public let body: APIRequestBody?
        public var timeoutInterval: TimeInterval = 10
        
        public typealias Response = AuthUser
    }
}

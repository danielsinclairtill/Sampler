//
//  User.swift
//  Sampler
//
//
//
//

import Foundation

public struct User: Codable, Equatable {
    public let id: Int?
    public let firstName: String?
    public let lastName: String?
    public let username: String?
    public let image: URL?
    
    enum CodingKeys: String, CodingKey {
        case id
        case firstName
        case lastName
        case username
        case image
    }
}

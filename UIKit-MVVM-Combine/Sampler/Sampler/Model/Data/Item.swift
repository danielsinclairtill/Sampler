//
//  Item.swift
//  Sampler
//
//
//
//

import UIKit

public struct Item: Codable, Equatable {
    @StringForced public var id: String?
    public let name: String?
    public let ingredients: [String]?
    public let difficulty: String?
    public let tags: [String]?
    @StringForced public var userId: String?
    public var user: User?
    public let image: URL?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case ingredients
        case difficulty
        case tags
        case userId
        case image
    }
}

extension Item: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

//
//  Item.swift
//  Sampler
//
//
//
//

import UIKit

public struct Item: Codable, Equatable, Hashable {
    /// Unique hashable id used for UICollectionViewDiffableDataSource.
    public var hashableID = UUID().uuidString

    public let id: Int?
    public let name: String?
    public let ingredients: [String]?
    public let difficulty: String?
    public let tags: [String]?
    public let userId: Int?
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
    
    var identifier: String {
        return hashableID
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    
    public static func == (lhs: Item, rhs: Item) -> Bool {
        return lhs.hashableID == rhs.hashableID
    }
}

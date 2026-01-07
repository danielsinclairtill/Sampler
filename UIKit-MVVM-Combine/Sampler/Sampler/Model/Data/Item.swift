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
    public let hashableID = UUID().uuidString

    public let id: String?
    public let title: String?
    public let user: User?
    public let cover: URL?
    public let description: String?
    public let tags: [String]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case user
        case cover
        case description
        case tags
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

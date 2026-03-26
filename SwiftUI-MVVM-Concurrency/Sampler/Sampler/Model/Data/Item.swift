//
//  Item.swift
//  Sampler
//
//
//
//

import UIKit
import SamplerAPI

public struct Item: Codable, Equatable {
    public var id: Int?
    public let title: String?
    public let body: String?
    public var user: User?
    public let image: URL?
}

extension Item: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Item {
    static func create(from: ItemCompactGraph?) -> Item? {
        guard let from else { return nil }
        return Item(id: from.id,
                    title: from.title,
                    body: from.body,
                    user: User.create(from: from.user.fragments.userGraph),
                    image: nil)
    }
}

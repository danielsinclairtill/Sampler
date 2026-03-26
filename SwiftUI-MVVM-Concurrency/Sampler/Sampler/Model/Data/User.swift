//
//  User.swift
//  Sampler
//
//
//
//

import Foundation
import SamplerAPI

public struct User: Codable, Equatable {
    public var id: Int?
    public let name: String?
    public let image: URL?
}

extension User {
    static func create(from: UserGraph) -> Self {
        User(name: from.name, image: nil)
    }
}

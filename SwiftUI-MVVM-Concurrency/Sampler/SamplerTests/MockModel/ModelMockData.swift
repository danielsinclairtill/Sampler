//
//  ModelMockData.swift
//  SamplerTests
//
//
//
//

import Foundation
@testable import Sampler

class ModelMockData {
    /// Make a mock item object with an id.
    static func makeItem(id: String,
                         userId: String? = nil,
                         user: User? = nil) -> Item {
        Item(id: id,
             name: "name \(id)",
             ingredients: ["ingredient1"],
             difficulty: "difficulty1",
             tags: ["tag1"],
             userId: userId ?? "\(id)",
             user: user ?? makeUser(id: id),
             image: URL(string: "image_url_\(id)"))
    }
    
    /// Make a count of mock item objects.
    static func makeMockItems(count: Int) -> [Item] {
        (0..<count).map { makeItem(id: String($0)) }
    }
    
    static func makeUser(id: String) -> User {
        User(id: id,
             firstName: "first",
             lastName: "last",
             username: "username",
             image: URL(string: "image_url_\(id)"))
    }
}

//
//  Item+Converter.swift
//  Sampler
//
//  Created by Daniel on 2026-01-30.
//

import Foundation
import CoreData

extension Item: StoreConvertible {
    static public var enitityName: String { "ItemCD" }
    
    public func convertToCD(context: NSManagedObjectContext) -> ItemCD {
        let itemCD = ItemCD(context: context)
        itemCD.id = id
        itemCD.difficulty = difficulty
        itemCD.image = image?.absoluteString
        itemCD.ingredients = ingredients
        itemCD.name = name
        itemCD.tags = tags
        if let user = user {
            itemCD.user = user.convertToCD(context: context)
        }

        return itemCD
    }

    public static func convertFromCD(_ itemCD: ItemCD) -> Item {
        var user: User? = nil
        if let userCD = itemCD.user {
            user = User.convertFromCD(userCD)
        }
        var image: URL? = nil
        if let coverURLString = itemCD.image {
            image = URL(string: coverURLString)
        }

        return Item(id: itemCD.id,
                    name: itemCD.name,
                    ingredients: itemCD.ingredients,
                    difficulty: itemCD.difficulty,
                    tags: itemCD.tags,
                    userId: user?.id,
                    user: user,
                    image: image)
    }
}

//
//  User+StoreConverter.swift
//  Sampler
//
//  Created by Daniel on 2026-01-30.
//

import Foundation
import CoreData

extension User: StoreConvertible {
    static public var enitityName: String { "UserCD" }

    public func convertToCD(context: NSManagedObjectContext) -> UserCD {
        let userCD = UserCD(context: context)
        userCD.id = id
        userCD.firstName = firstName
        userCD.image = image?.absoluteString
        userCD.lastName = lastName
        userCD.username = username
        
        return userCD
    }
    
    public static func convertFromCD(_ userCD: UserCD) -> User {
        var image: URL? = nil
        if let imageURLString = userCD.image {
            image = URL(string: imageURLString)
        }

        return User(id: userCD.id,
                    firstName: userCD.firstName,
                    lastName: userCD.lastName,
                    username: userCD.username,
                    image: image)
    }
}

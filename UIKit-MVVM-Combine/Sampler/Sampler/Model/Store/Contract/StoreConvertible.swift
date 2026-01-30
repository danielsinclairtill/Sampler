//
//  StoreConvertible.swift
//  Sampler
//
//  Created by Daniel on 2026-01-30.
//

import CoreData

public protocol StoreConvertible {
    associatedtype CD
    static var enitityName: String { get }
    
    func convertToCD(context: NSManagedObjectContext) -> CD
    
    static func convertFromCD(_ cd: CD) -> Self
}

//
//  StringForced.swift
//  Sampler
//
//  Created by Daniel on 2026-01-08.
//

import Foundation

/// A type to force to be decoded into a String type.
@propertyWrapper
public struct StringForced: Codable, Equatable {
    public var wrappedValue: String?
    
    public init(wrappedValue: String?) { self.wrappedValue = wrappedValue }
    
    public init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        if c.decodeNil() { wrappedValue = nil; return }
        if let s = try? c.decode(String.self) { wrappedValue = s; return }
        if let i = try? c.decode(Int.self) { wrappedValue = String(i); return }
        if let d = try? c.decode(Double.self) { wrappedValue = String(d); return }
        throw DecodingError.typeMismatch(String.self, .init(codingPath: decoder.codingPath,
                                                            debugDescription: "Expected String/Int/Double"))
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        if let value = wrappedValue {
            try container.encode(value)
        } else {
            try container.encodeNil()
        }
    }
}

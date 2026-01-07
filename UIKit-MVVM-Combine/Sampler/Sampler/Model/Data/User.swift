//
//  User.swift
//  Sampler
//
//
//
//

import Foundation

public struct User: Codable, Equatable {
    public let name: String?
    public let avatar: URL?
    public let fullname: String?
    
    enum CodingKeys: String, CodingKey {
        case name
        case avatar
        case fullname
    }
}

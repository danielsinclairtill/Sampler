//
//  AuthUser.swift
//  Sampler
//
//  Created by Daniel on 2026-01-10.
//

import Foundation

public struct AuthUser: Codable, Equatable {
    @StringForced public var id: String?
    public let firstName: String?
    public let lastName: String?
    public let username: String?
    public let image: URL?
    public let accessToken: String?
    public let refreshToken: String?
}

//
//  AuthRepository.swift
//  Sampler
//
//  Created by Daniel on 2026-04-14.
//

import Foundation

protocol AuthRepositoryContract {
    func login(username: String, password: String) async throws -> AuthUser
}

class AuthRepository: AuthRepositoryContract {
    private let api: APIContract
    
    init(api: APIContract) {
        self.api = api
    }

    func login(username: String, password: String) async throws -> AuthUser {
        try await api.request(LoginAPIRequest.Login(username: username, password: password))
    }
}

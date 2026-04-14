//
//  UserRepository.swift
//  Sampler
//
//  Created by Daniel on 2026-03-31.
//

import Foundation

protocol UserRepositoryContract {
    func getUser(id: String) async throws -> DataResult<User>
}

class UserRepository: UserRepositoryContract {
    private let api: APIContract
    
    init(api: APIContract) {
        self.api = api
    }

    func getUser(id: String) async throws -> DataResult<User> {
        // item from API
        let item = try await api.request(UserAPIRequest.Detail(id: id))
        return .init(data: item, source: .api)
    }
}

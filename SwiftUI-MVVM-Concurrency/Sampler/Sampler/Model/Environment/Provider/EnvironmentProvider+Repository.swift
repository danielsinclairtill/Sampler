//
//  EnvironmentProvider+Repository.swift
//  Sampler
//
//  Created by Daniel on 2026-03-31.
//

protocol ItemRepositoryProvider {
    var itemRepository: ItemRepositoryContract { get }
}

protocol UserRepositoryProvider {
    var userRepository: UserRepositoryContract { get }
}

protocol AuthRepositoryProvider {
    var authRepository: AuthRepositoryContract { get }
}


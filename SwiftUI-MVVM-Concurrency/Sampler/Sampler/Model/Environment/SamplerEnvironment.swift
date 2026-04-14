//
//  SamplerEnvironment.swift
//  Sampler
//
//
//

import Foundation
import SwiftUI

@Observable
class SamplerEnvironment: EnvironmentContract {
    static let shared: SamplerEnvironment = {
        if SamplerEnvironment.isTesting {
            SamplerEnvironment.mock
        } else {
            SamplerEnvironment.production
        }
    }()
    
    let api: APIContract
    let imageManager: ImageManagerContract
    let store: StoreContract
    let state: any SamplerStateContract
    let likeManager: any LikeManagerContract
    
    init(api: APIContract = SamplerAPI(),
         imageManager: ImageManagerContract = SamplerAPIImageManager(),
         store: StoreContract = SamplerStore(container: SamplerStore.persistentContainer()),
         state: any SamplerStateContract = SamplerStateManager()) {
        self.api = api
        self.imageManager = imageManager
        self.store = store
        self.state = state
        self.likeManager = LikeManager(state: state)
    }
}

extension SamplerEnvironment {
    static let production = SamplerEnvironment()
    
    static let mock = SamplerEnvironment(api: SamplerAPI(),
                                         store: SamplerTestStore(),
                                         state: SamplerStateManager())
}

// MARK: Provider + Data

extension SamplerEnvironment: APIProvider {}
extension SamplerEnvironment: ImageMangagerProvider {}
extension SamplerEnvironment: StoreProvider {}
extension SamplerEnvironment: StateProvider {}
extension SamplerEnvironment: LikeManagerProvider {}

// MARK: Provider + Repository

extension SamplerEnvironment: ItemRepositoryProvider {
    var itemRepository: ItemRepositoryContract {
        return ItemRepository(api: api, store: store)
    }
}

extension SamplerEnvironment: UserRepositoryProvider {
    var userRepository: UserRepositoryContract {
        return UserRepository(api: api)
    }
}

extension SamplerEnvironment: AuthRepositoryProvider {
    var authRepository: AuthRepositoryContract {
        return AuthRepository(api: api)
    }
}

//
//  SamplerEnvironmentMock.swift
//  SamplerTests
//
//
//
//

import Foundation
@testable import Sampler

class SamplerEnvironmentMock: EnvironmentContract {
    
    
    var api: APIContract { mockApi }
    var imageManager: ImageManagerContract { mockImageManager }
    var state: any SamplerStateContract { mockState }
    var store: StoreContract { mockStore }
    var likeManager: any LikeManagerContract { mockLikeManager }
    
    let mockApi = SamplerAPIMock()
    let mockImageManager = SamplerImageManagerMock()
    let mockStore = SampleStoreMock()
    let mockState = SamplerStateManagerMock()
    let mockLikeManager = SamplerLikeManagerMock()

    /// Reset and clear the mock environment state.
    func reset() {
        mockApi.reset()
    }
}

// MARK: Provider + Data

extension SamplerEnvironmentMock: APIProvider {}
extension SamplerEnvironmentMock: ImageMangagerProvider {}
extension SamplerEnvironmentMock: StoreProvider {}
extension SamplerEnvironmentMock: StateProvider {}
extension SamplerEnvironmentMock: LikeManagerProvider {}

// MARK: Provider + Repository

extension SamplerEnvironmentMock: ItemRepositoryProvider {
    var itemRepository: ItemRepositoryContract {
        return ItemRepository(api: api, store: store)
    }
}

extension SamplerEnvironmentMock: UserRepositoryProvider {
    var userRepository: UserRepositoryContract {
        return UserRepository(api: api)
    }
}

extension SamplerEnvironmentMock: AuthRepositoryProvider {
    var authRepository: AuthRepositoryContract {
        return AuthRepository(api: api)
    }
}

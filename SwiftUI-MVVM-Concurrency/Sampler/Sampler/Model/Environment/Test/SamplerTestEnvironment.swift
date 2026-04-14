//
//  SamplerEnvironment.swift
//  Sampler
//
//
//

import Foundation
import Combine

class SamplerTestEnvironment: EnvironmentContract {
    static let shared = SamplerTestEnvironment()
    
    let api: APIContract = SamplerAPI()
    let store: StoreContract = SamplerTestStore()
    let state: any SamplerStateContract = SamplerStateManager()
    lazy var likeManager: any LikeManagerContract = LikeManager(state: state)
}

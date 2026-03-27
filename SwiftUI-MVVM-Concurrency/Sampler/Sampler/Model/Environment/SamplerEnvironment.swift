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
    let store: StoreContract
    var state: any SamplerStateContract
    
    let likeManager: any LikeManagerContract
    
    init(api: APIContract = SamplerAPI(),
         store: StoreContract = SamplerStore(container: SamplerStore.persistentContainer()),
         state: any SamplerStateContract = SamplerStateManager()) {
        self.api = api
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

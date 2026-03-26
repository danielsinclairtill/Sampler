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
    var state: any SamplerStateContract
    
    init(api: APIContract = SamplerAPI(),
         state: any SamplerStateContract = SamplerStateManager()) {
        self.api = api
        self.state = state
    }
}

extension SamplerEnvironment {
    static let production = SamplerEnvironment()
    
    static let mock = SamplerEnvironment(api: SamplerAPI(),
                                         state: SamplerStateManager())
}

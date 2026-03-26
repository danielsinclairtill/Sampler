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
    let state: any SamplerStateContract = SamplerStateManager()
}

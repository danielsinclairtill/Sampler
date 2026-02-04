//
//  SamplerEnvironment.swift
//  Sampler
//
//
//

import Foundation
import UIKit

class SamplerTestEnvironment: EnvironmentContract {
    static let shared = SamplerTestEnvironment()
    
    let api: APIContract = SamplerAPI()
    let store: StoreContract = SamplerTestStore()
    let state: SamplerStateContract = SamplerStateManager()
}

//
//  SamplerEnvironment.swift
//  Sampler
//
//
//

import Foundation
import UIKit

class SamplerEnvironment: EnvironmentContract {
    static let shared = SamplerEnvironment()
    
    let api: APIContract = SamplerAPI()
    let store: StoreContract = SamplerStore(container: SamplerStore.persistentContainer())
    let state: SamplerStateContract = SamplerStateManager()
}

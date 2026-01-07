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
    let state: SamplerStateContract = SamplerStateManager()
}

//
//  EnvironmentContract.swift
//  Sampler
//
//
//

import Foundation

protocol EnvironmentContract {
    var api: APIContract { get }
    var store: StoreContract { get }
    var state: SamplerStateContract { get }
}

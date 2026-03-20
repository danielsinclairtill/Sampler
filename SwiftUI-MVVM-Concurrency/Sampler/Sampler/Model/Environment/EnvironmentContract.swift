//
//  EnvironmentContract.swift
//  Sampler
//
//
//

import Foundation

protocol EnvironmentContract: ObservableObject {
    var api: APIContract { get }
    var store: StoreContract { get }
    var state: any SamplerStateContract { get }
}

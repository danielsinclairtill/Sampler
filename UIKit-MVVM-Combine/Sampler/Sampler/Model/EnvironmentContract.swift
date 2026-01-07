//
//  EnvironmentContract.swift
//  Sampler
//
//
//

import Foundation

protocol EnvironmentContract {
    var api: APIContract { get }
    var state: SamplerStateContract { get }
}

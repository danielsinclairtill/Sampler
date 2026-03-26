//
//  EnvironmentContract.swift
//  Sampler
//
//
//

import Foundation

protocol EnvironmentContract: AnyObject, Observable {
    var api: APIContract { get }
    var state: any SamplerStateContract { get }
}

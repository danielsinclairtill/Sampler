//
//  SamplerViewModel.swift
//  Sampler
//
//
//

import Foundation

protocol SamplerViewModel {
    associatedtype Input
    associatedtype Output

    var input: Input { get }
    var output: Output { get }
}

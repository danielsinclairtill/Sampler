//
//  SamplerViewModel.swift
//  Sampler
//
//
//

import Foundation

protocol SamplerViewModelContract {
    associatedtype Input
    associatedtype Output

    var input: Input { get }
    var output: Output { get }
}

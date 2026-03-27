//
//  SamplerViewModel.swift
//  Sampler
//
//
//

import Foundation
import SwiftUI

protocol SamplerViewModelContract {
    associatedtype Output

    var output: Output { get set }
}

protocol SamplerViewModelContractNew {
    associatedtype Input
    associatedtype Output

    var input: Input { get }
    var output: Output { get }
}

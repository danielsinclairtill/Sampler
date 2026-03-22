//
//  SamplerViewModel.swift
//  Sampler
//
//
//

import Foundation
import SwiftUI

protocol SamplerViewModelContract: ObservableObject {
    associatedtype Input
    associatedtype Output

    var input: Input { get set }
    var output: Output { get }
}

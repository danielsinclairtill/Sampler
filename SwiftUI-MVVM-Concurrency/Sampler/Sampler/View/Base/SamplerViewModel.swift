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

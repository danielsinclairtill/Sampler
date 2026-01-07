//
//  SamplerStateContract.swift
//  Sampler
//
//
//

import Foundation

protocol SamplerStateContract: AnyObject {
    /// The current design theme of the application.
    var theme: SamplerDesignTheme { get set }
}

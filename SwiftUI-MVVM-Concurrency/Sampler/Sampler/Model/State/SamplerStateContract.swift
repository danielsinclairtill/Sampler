//
//  SamplerStateContract.swift
//  Sampler
//
//
//

import Foundation

protocol SamplerStateContract: ObservableObject {
    /// If the user is currently logged in.
    var user: AuthUser? { get set }
    
    /// The current design theme of the application.
    var theme: SamplerDesignTheme { get set }
}

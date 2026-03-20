//
//  SamplerDesign.swift
//  Sampler
//
//
//
//

import Foundation
import UIKit
import Combine

class SamplerDesign {
    static let shared = SamplerDesign()
    @Published private(set) var theme: SamplerDesignTheme = .plain
    private let state: any SamplerStateContract
    
    init(state: any SamplerStateContract = SamplerEnvironment.shared.state) {
        self.state = state
        self.theme = state.theme
    }
    
    /// Change the theme of the design system of the application. This will update displayed components colors, fonts, dimensions, etc.
    /// - Parameter theme: The new theme to change to.
    func changeToTheme(_ theme: SamplerDesignTheme) {
        self.state.theme = theme
        self.theme = theme
    }
}

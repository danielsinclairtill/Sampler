//
//  SamplerStateManager.swift
//  Sampler
//
//
//
//

import Foundation

class SamplerStateManager: SamplerStateContract {
    static let shared: SamplerStateManager = SamplerStateManager()
    private let defaults = UserDefaults.standard

    var theme: SamplerDesignTheme {
        get {
            guard let themeString = defaults.string(forKey: "theme"),
                    let theme = SamplerDesignTheme(rawValue: themeString) else {
                return .plain
            }
            return theme
        }
        set (newValue) {
            defaults.set(newValue.rawValue, forKey: "theme")
        }
    }
}

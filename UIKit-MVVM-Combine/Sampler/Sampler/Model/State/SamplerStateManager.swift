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
    
    var user: AuthUser? {
        get {
            if let userData = UserDefaults.standard.data(forKey: "user"),
               let user = try? JSONDecoder().decode(AuthUser.self, from: userData) {
                return user
            } else {
                return nil
            }
        }
        set (newValue) {
            if let encodedUser = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(encodedUser, forKey: "user")
            }
        }
    }

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

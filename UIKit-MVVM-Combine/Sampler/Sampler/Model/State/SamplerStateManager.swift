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
    private let defaults: UserDefaults
    
    private enum Keys {
        static let user = "user"
        static let theme = "theme"
    }
    
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }
    
    // no secure, should be in keychain
    var user: AuthUser? {
        get {
            if let userData = UserDefaults.standard.data(forKey: Keys.user),
               let user = try? JSONDecoder().decode(AuthUser.self, from: userData) {
                return user
            } else {
                return nil
            }
        }
        set (newValue) {
            if let encodedUser = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(encodedUser, forKey: Keys.user)
            }
        }
    }

    var theme: SamplerDesignTheme {
        get {
            guard let themeString = defaults.string(forKey: Keys.theme),
                    let theme = SamplerDesignTheme(rawValue: themeString) else {
                return .plain
            }
            return theme
        }
        set (newValue) { defaults.set(newValue.rawValue, forKey: Keys.theme) }
    }
}

//
//  SamplerStateManager.swift
//  Sampler
//
//
//
//

import Foundation
import Combine

@Observable
class SamplerStateManager: SamplerStateContract {
    static let shared: SamplerStateManager = SamplerStateManager()
    private let defaults: UserDefaults
    
    private enum Keys {
        static let user = "user"
        static let theme = "theme"
    }
    
    // no secure, should be in keychain
    var user: AuthUser? {
        didSet {
            if let encodedUser = try? JSONEncoder().encode(user) {
                defaults.set(encodedUser, forKey: Keys.user)
            }
        }
    }

    var theme: SamplerDesignTheme {
        didSet {
            defaults.set(theme.rawValue, forKey: Keys.theme)
        }
    }
    
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        
        // Load user from UserDefaults
        if let userData = defaults.data(forKey: Keys.user),
           let user = try? JSONDecoder().decode(AuthUser.self, from: userData) {
            self.user = user
        } else {
            self.user = nil
        }
        
        // Load theme from UserDefaults
        if let themeString = defaults.string(forKey: Keys.theme),
           let theme = SamplerDesignTheme(rawValue: themeString) {
            self.theme = theme
        } else {
            self.theme = .plain
        }
    }
}

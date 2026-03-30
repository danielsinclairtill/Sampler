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
    private let defaults: UserDefaults
    
    private enum Keys: String {
        case user
        case theme
        case likedItemIds
    }
    
    // no secure, should be in keychain
    var user: AuthUser? {
        didSet {
            if let encodedUser = try? JSONEncoder().encode(user) {
                defaults.set(encodedUser, forKey: Keys.user.rawValue)
            }
        }
    }

    var theme: SamplerDesignTheme {
        didSet {
            defaults.set(theme.rawValue, forKey: Keys.theme.rawValue)
        }
    }
    
    var likedItemIds: [String] {
        didSet {
            if let encoded = try? JSONEncoder().encode(likedItemIds) {
                defaults.set(encoded, forKey: Keys.likedItemIds.rawValue)
            }
        }
    }
    
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        
        // user
        if let userData = defaults.data(forKey: Keys.user.rawValue),
           let user = try? JSONDecoder().decode(AuthUser.self, from: userData) {
            self.user = user
        } else {
            self.user = nil
        }
        
        // theme
        if let themeString = defaults.string(forKey: Keys.theme.rawValue),
           let theme = SamplerDesignTheme(rawValue: themeString) {
            self.theme = theme
        } else {
            self.theme = .plain
        }
        
        // likedItemIds
        if let data = defaults.data(forKey: Keys.likedItemIds.rawValue),
           let decoded = try? JSONDecoder().decode([String].self, from: data) {
            self.likedItemIds = decoded
        } else {
            self.likedItemIds = []
        }
    }
}

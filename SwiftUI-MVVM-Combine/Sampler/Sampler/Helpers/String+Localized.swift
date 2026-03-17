//
//  String+Localized.swift
//  Sampler
//
//
//

import Foundation

extension String {
    /// Retrieve the localized string value for a localization ID string.
    func localized(withComment: String = "") -> String {
        let localizedString = NSLocalizedString(self, tableName: nil, bundle: Bundle.main, comment: self)
        guard localizedString != self else {
            assertionFailure(String(format: "Cannot find value for localized string: %@", self))
            return ""
        }
        return localizedString
    }
}

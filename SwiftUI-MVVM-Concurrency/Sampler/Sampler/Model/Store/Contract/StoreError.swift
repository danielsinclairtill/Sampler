//
//  StoreError.swift
//  Stories
//
//
//
//

import Foundation

public enum StoreError: Error {
    /// Error reading data from the store.
    case readError
    /// Error writing data to the store.
    case writeError
    /// No results where found
    
    var message: String {
        switch self {
        case .readError:
            "Read Error!"
        case .writeError:
            "Write Error!"
        }
    }
}

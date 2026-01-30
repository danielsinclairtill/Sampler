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
    
    var message: String {
        switch self {
        case .readError:
            "Read Error!"
        case .writeError:
            "Write Error!"
        }
    }
}

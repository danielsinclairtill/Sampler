//
//  SamplerDesignTheme.swift
//  Sampler
//
//
//
//

import Foundation

public enum SamplerDesignTheme: String, CaseIterable {
    case plain
    
    var attributes: Attributes {
        switch self {
        case .plain:
            return PlainTheme()
        }
    }
}

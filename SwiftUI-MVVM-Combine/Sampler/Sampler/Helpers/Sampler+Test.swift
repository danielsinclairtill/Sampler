//
//  ProcessInfo+Testing.swift
//  Sampler
//
//  Created by Daniel on 2026-02-04.
//

import Foundation

extension SamplerEnvironment {
    static var isTesting: Bool {
        ProcessInfo.processInfo.environment["IS_TEST"] == "1"
    }
}

//
//  ObserveBag.swift
//  Sampler
//
//  Created by Daniel on 2026-03-23.
//

import Foundation

@MainActor
final class ObserveBag {
    private var tasks: [Task<Void, Never>] = []

    func add(tracking: @escaping @Sendable @MainActor () -> Void) {
        let task = Task { @MainActor in
            while !Task.isCancelled {
                await withCheckedContinuation { continuation in
                    withObservationTracking {
                        tracking()
                    } onChange: {
                        continuation.resume()
                    }
                }
            }
        }
        tasks.append(task)
    }

    deinit {
        tasks.forEach { $0.cancel() }
        tasks.removeAll()
    }
}

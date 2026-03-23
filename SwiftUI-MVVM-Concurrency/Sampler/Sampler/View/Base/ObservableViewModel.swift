//
//  ObservableViewModel.swift
//  Sampler
//
//  Created by Daniel on 2026-03-23.
//

import Foundation

// MARK: - AutoCancellingTask
final private class AutoCancellingTask {
    private var tasks: [Task<Void, Never>] = []

    func add(_ task: Task<Void, Never>) {
        tasks.append(task)
    }

    deinit {
        tasks.forEach { $0.cancel() }
        tasks.removeAll()
    }
}

// MARK: - ObservationTracking
private enum ObservationTracking {
    @MainActor
    @discardableResult
    static func observe(
        tracking: @escaping @MainActor () -> Void,
        onChange: @escaping @MainActor () -> Void
    ) -> Task<Void, Never> {
        Task { @MainActor in
            while !Task.isCancelled {
                await withCheckedContinuation { continuation in
                    withObservationTracking {
                        tracking()
                    } onChange: {
                        continuation.resume()
                    }
                }
                guard !Task.isCancelled else { return }
                onChange()
            }
        }
    }
}

// MARK: - ObservableViewModel
@MainActor
class ObservableViewModel {
    private var observations = AutoCancellingTask()

    func observe(
        tracking: @escaping @MainActor () -> Void,
        onChange: @escaping @MainActor () -> Void
    ) {
        observations.add(
            ObservationTracking.observe(tracking: tracking, onChange: onChange)
        )
    }
}

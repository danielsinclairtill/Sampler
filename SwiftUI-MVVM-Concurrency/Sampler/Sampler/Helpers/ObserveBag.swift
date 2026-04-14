//
//  ObserveBag.swift
//  Sampler
//
//  Created by Daniel on 2026-03-23.
//

import Foundation

/// A lifetime-scoped container for `@Observable` observation tasks.
///
/// `ObserveBag` allows you to reactively sync state from any `@Observable` object
/// into your ViewModel. Each observation tracks whichever
/// `@Observable` properties are read inside the `tracking` closure, and re-runs
/// automatically whenever any of those properties change.
///
/// Observations are cancelled automatically when the bag is deallocated,
/// making cleanup effortless when used as a stored property on a ViewModel.
///
/// Usage:
/// ```swift
/// private let observations = ObserveBag()
///
/// private func setupObservations() {
///     observations.add { [weak self] in
///         guard let self else { return }
///         self.output.isLiked = self.likeManager.isLiked(self.itemId)
///     }
/// }
/// ```
@MainActor
final class ObserveBag {
    private var tasks: [Task<Void, Never>] = []

    /// Adds a new observation that tracks any `@Observable` properties read
    /// inside the `tracking` closure.
    ///
    /// The closure is executed immediately to register dependencies, then
    /// re-executed each time any of those dependencies change. This continues
    /// until the bag is deallocated or the underlying task is cancelled.
    ///
    /// - Parameter tracking: A closure that reads from one or more `@Observable`
    ///   properties. Any property accessed during execution is automatically
    ///   tracked as a dependency. The closure runs on the `@MainActor`.
    func add(tracking: @escaping @Sendable @MainActor () -> Void) {
        let task = Task { @MainActor in
            while !Task.isCancelled {
                let box = ContinuationBox()
                
                await withTaskCancellationHandler {
                    await withCheckedContinuation { continuation in
                        box.store(continuation)
                        withObservationTracking {
                            tracking()
                        } onChange: {
                            // Called once when any tracked dependency changes.
                            // Resumes the continuation to trigger the next loop iteration,
                            // which re-registers the observation fresh.
                            box.resume()
                        }
                    }
                } onCancel: {
                    box.resume()
                }
            }
        }
        tasks.append(task)
    }

    /// Cancels all active observation tasks.
    ///
    /// Called automatically when the bag is deallocated, ensuring no
    /// observations outlive the object that owns the bag.
    deinit {
        tasks.forEach { $0.cancel() }
        tasks.removeAll()
    }
}

/// Thread-safe box ensuring the continuation is resumed exactly once
nonisolated private final class ContinuationBox: @unchecked Sendable {
    private var continuation: CheckedContinuation<Void, Never>?
    private let lock = NSLock()

    func store(_ cont: CheckedContinuation<Void, Never>) {
        lock.withLock { continuation = cont }
    }

    func resume() {
        lock.withLock {
            continuation?.resume()
            continuation = nil  // nil out so a second call is a no-op
        }
    }
}

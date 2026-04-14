//
//  Debounce.swift
//  Sampler
//
//  Created by Daniel on 2026-04-14.
//

import Foundation

actor Debounce<each Parameter: Sendable>: Sendable {
    private let action: @Sendable (repeat each Parameter) async -> Void
    private let delay: Duration
    nonisolated(unsafe) var task: Task<Void, Never>?

    init(for dueTime: Duration,
         _ action: @Sendable @escaping (repeat each Parameter) async -> Void) {
        self.action = action
        self.delay = dueTime
    }

    func callAsFunction(_ parameter: repeat each Parameter) {
        task?.cancel()
        task = Task {
            try? await Task.sleep(for: delay)
            guard !Task.isCancelled else { return }
            await action(repeat each parameter)
        }
    }

    func cancel() {
        task?.cancel()
        task = nil
    }
    
    deinit {
        task?.cancel()
        task = nil
    }
}

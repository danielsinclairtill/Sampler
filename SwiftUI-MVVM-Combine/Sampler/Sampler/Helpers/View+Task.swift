//
//  View+Task.swift
//  Sampler
//
//  Created by Daniel on 2026-03-18.
//

import SwiftUI

struct OnAppearOnceModifier: ViewModifier {
    @State private var hasLoaded = false
    let action: () async -> Void

    func body(content: Content) -> some View {
        content
            .task {
                guard !hasLoaded else { return }
                hasLoaded = true
                await action()
            }
    }
}

extension View {
    func onAppearOnce(_ action: @escaping () async -> Void) -> some View {
        modifier(OnAppearOnceModifier(action: action))
    }
}
